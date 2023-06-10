# coding=utf-8
import torch
import torch.utils.data as Data
from tqdm import tqdm
from sklearn.metrics import auc
from argparse import ArgumentParser
from scipy.io import savemat

from method import Predict
from metrics import SegmentationMetricTPFNFP, ROCMetric
from data import *

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
    #
    # Evaluation parameters
    #
    parser.add_argument('--batch-size', type=int, default=1, help='batch size for training')
    parser.add_argument('--ngpu', type=int, default=0, help='GPU number')

    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = parse_args()
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
    else:
        raise NotImplementedError
    data_loader = Data.DataLoader(dataset, batch_size=args.batch_size, shuffle=False)

    # metrics
    metrics = SegmentationMetricTPFNFP(nclass=1)
    metric_roc = ROCMetric(nclass=1, bins=200)
    # ['ADDGD', 'ADMD', 'HBMLCM', 'ILCM', 'LEF', 'LIG', 'MAXMEAN', 'MSAAGD', 'MSLoG', 'MSPCM', 'PSTNN', 'RLCM', 'TLLCM', 'TopHat', 'var_diff', 'WSLCM']
    model = Predict(name="ILCM", dataset=data_loader.dataset.name)
    model.save_result = False
    # evaluation
    tbar = tqdm(data_loader)
    for i, (data, labels) in enumerate(tbar):
        output = model(data)
        metrics.update(labels=labels, preds=output)
        metric_roc.update(labels=labels, preds=output)

    miou, prec, recall, fmeasure = metrics.get()
    tpr, fpr = metric_roc.get()
    auc_value = auc(fpr, tpr)
    # show results
    print('Precision: %.4f | Recall: %.4f | mIoU: %.4f | F-measure: %.4f | AUC: %.4f'
          % (prec, recall, miou, fmeasure, auc_value))
    savemat('evulate.mat', {'miou': miou, 'prec': prec, 'recall': recall, 'fmeasure': fmeasure, 'auc': auc_value, 'tpr': tpr, 'fpr': fpr })


