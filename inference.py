# coding=utf-8
import matlab
import matlab.engine as engine
import numpy as np 
import torch 
from tqdm import tqdm
import os 
import torch.utils.data as Data
import cv2 
from argparse import ArgumentParser
from data import *
from method import *
import random

class Inference(Predict):
    """
    Single thread for matlab
    """
    def __init__(self,  name, dataset):
        super(Inference, self).__init__(name, dataset)
        """
        name: name of matlab function
        dataset: dataset for evaluation
        """
        super(Predict, self).__init__()
        self.save_result = True
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
        out[out> np.max(out)*0.5] = 1
        if out.shape != img.shape:
            out = cv2.resize(out, img.shape)
        if self.save_result:
            img_save = out.copy()
            img_save = np.uint8(img_save * 255)
            cv2.imwrite(f"results/{self.dataset}_{self.name}/{self.index}.png", img_save)
            self.index += 1
    

class InferMultiThread(MultiThread):
    def __init__(self, name, dataloader):
        super().__init__(name, dataloader)
        self.model = Inference(name, dataloader.dataset.name)
    
    def run(self):
        for data, _ in tqdm(self.data_loader):
            _ = self.model(data)

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
    random.seed(1024)
    np.random.seed(1024)
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
    methods = os.listdir("detector")
    print(methods)
    methods = ['ILCM', 'MAXMEAN', 'MSLoG', 'MSPCM']
    # ['ADDGD', 'ADMD', 'HBMLCM', 'ILCM', 'LEF', 'LIG', 'MAXMEAN', 'MSAAGD', 'MSLoG', 'MSPCM', 'PSTNN', 'RLCM', 'TLLCM', 'TopHat', 'var_diff', 'WSLCM']
    threads = [InferMultiThread(name, data_loader) for name in methods]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()