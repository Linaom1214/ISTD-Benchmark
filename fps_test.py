# coding=utf-8
import matlab
import matlab.engine as engine
from threading import Thread
import numpy as np 
import torch 
from tqdm import tqdm
import os 
import torch.utils.data as Data
from argparse import ArgumentParser
import time 

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

    def __call__(self, img):
        img  = img[0, 0, ...].detach().numpy()
        img = np.uint8(img * 255)
        list_img = img.tolist()
        m_img = matlab.double(list_img)
        out = eval("%s" % self.fun_string)
        return out
    

class MultiThread(Thread):
    def __init__(self, name, dataloader):
        super().__init__()
        self.name = name
        self.model = Predict(name, dataloader.dataset.name)
        self.data_loader = dataloader
        self.data_loader_name = dataloader.dataset.name
    
    def run(self):
        for data, _ in self.data_loader:
            start_time = time.time()
            output = self.model(data)
            end_time = time.time()
            print(f"FPS of {self.name} on {self.data_loader_name} is {1 / (end_time - start_time)}")
            break

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