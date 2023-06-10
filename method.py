# coding=utf-8
import matlab
import matlab.engine as engine
from threading import Thread
import numpy as np 
import torch 
from tqdm import tqdm
from sklearn.metrics import auc
import os 
import torch.utils.data as Data
import cv2 
from scipy.io import savemat
from argparse import ArgumentParser

from metrics import SegmentationMetricTPFNFP, ROCMetric
from data import *

class UnNormalize(object):
    "UnNormalize tensor image "
    def __init__(self, mean, std):
        self.mean = mean
        self.std = std

    def __call__(self, tensor):
        """
        Args:
            tensor (Tensor): Tensor image of size (C, H, W) to be normalized.
        Returns:
            Tensor: Normalized image.
        """
        for t, m, s in zip(tensor, self.mean, self.std):
            t.mul_(s).add_(m)
            # The normalize code -> t.sub_(m).div_(s)
        return tensor

class Predict():
    """
    Single thread for matlab
    """
    def __init__(self,  name, dataset):
        """
        name: name of matlab function
        dataset: dataset for evaluation
        """
        super(Predict, self).__init__()
        self.name = name
        self.dataset = dataset
        self.fun_string = f"self.eg.run_{name}(m_img)"
        self.eg = engine.start_matlab() 
        self.eg.cd(f"detector/{name}")
        self.index = 0
        self.save_result = False
        if self.save_result:
            try:
                os.makedirs(f"results/{self.dataset}_{name}")
            except:
                pass

    def __call__(self, img):
        img  = img[0, 0, ...].detach().numpy()
        img = np.uint8(img * 255)
        list_img = img.tolist()
        m_img = matlab.double(list_img)
        out = eval("%s" % self.fun_string)
        out = np.array(out, np.float32)
        out = np.nan_to_num(out)
        out = (out - out.min()) / (out.max() - out.min())
        out[out< np.max(out)*0.5] = 0
        if out.shape != img.shape:
            out = cv2.resize(out, img.shape)
        if self.save_result:
            img_save = out.copy()
            img_save = np.uint8(img_save * 255)
            cv2.imwrite(f"results/{self.dataset}_{self.name}/{self.index}.png", img_save)
            self.index += 1
        out = torch.from_numpy(out)
        return out
    

class MultiThread(Thread):
    def __init__(self, name, dataloader):
        super().__init__()
        self.name = name
        self.metrics = SegmentationMetricTPFNFP(nclass=1)
        self.metric_roc = ROCMetric(nclass=1, bins=200)
        self.model = Predict(name, dataloader.dataset.name)
        self.data_loader = dataloader
        self.data_loader_name = dataloader.dataset.name
    
    def run(self):
        for data, labels in tqdm(self.data_loader):
            output = self.model(data)
            self.metrics.update(labels=labels, preds=output)
            self.metric_roc.update(labels=labels, preds=output)

        miou, prec, recall, fmeasure = self.metrics.get()
        tpr, fpr = self.metric_roc.get()
        auc_value = auc(fpr, tpr)
        print(self.name,'Precision: %.4f | Recall: %.4f | mIoU: %.4f | F-measure: %.4f | AUC: %.4f'
            % (prec, recall, miou, fmeasure, auc_value))
        savemat(f'save/{self.data_loader_name}_{self.name}_evulate.mat', {'miou': miou, 'prec': prec, 'recall': recall, 'fmeasure': fmeasure, 'auc': auc_value, 'tpr': tpr, 'fpr': fpr })

def parse_args():
    #
    # Setting parameters
    #
    parser = ArgumentParser(description='Evaluation of Matlab methods')
    #
    # Dataset parameters
    #
    parser.add_argument('--base-size', type=int, default=256, help='base size of images')
    parser.add_argument('--dataset', type=str, default='mdfa', help='choose datasets')
    parser.add_argument('--sirstaug-dir', type=str, default=r'dataset\sirst_aug',
                        help='dir of dataset')
    parser.add_argument('--mdfa-dir', type=str, default=r'dataset\MDvsFA_cGAN\data',
                        help='dir of dataset')
    parser.add_argument('--irstd-dir', type=str, default=r'dataset\IRSTD-1k',
                        help='dir of dataset')
    args = parser.parse_args()
    return args



if __name__ == "__main__":
    args = parse_args()
    # torch.seed(1024)
    torch.manual_seed(1024)
    # set device
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    # define dataset
    if args.dataset == 'sirstaug':
        dataset = SirstAugDataset(base_dir=args.sirstaug_dir, mode='test')
    elif args.dataset == 'mdfa':
        dataset = MDFADataset(base_dir=args.mdfa_dir, mode='test', base_size=args.base_size)
    elif args.dataset == 'merged':
        dataset = MergedDataset(mdfa_base_dir=args.mdfa_dir,
                                sirstaug_base_dir=args.sirstaug_dir,
                                mode='test', base_size=args.base_size)
    elif args.dataset == 'irstd':
        dataset = IRSTDDataset(base_dir=args.irstd_dir, mode='test')
    else:
        raise NotImplementedError
    data_loader = Data.DataLoader(dataset, batch_size=1, shuffle=False)
    methods = os.listdir("detector") # Use total methods in detector folder or  methods = ['ILCM', 'MAXMEAN', 'MSLoG', 'MSPCM']
    threads = [MultiThread(name, data_loader) for name in methods]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()