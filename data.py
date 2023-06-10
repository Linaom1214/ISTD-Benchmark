import torch.utils.data as Data
import torchvision.transforms as transforms

from PIL import Image
import os
import os.path as osp

__all__ = ['SirstAugDataset', 'MDFADataset', 'MergedDataset', 'IRSTDDataset']


class MergedDataset(Data.Dataset):
    def __init__(self, mdfa_base_dir='../data/MDFA', sirstaug_base_dir='../data/sirst_aug', mode='train', base_size=256):
        assert mode in ['train', 'test']

        self.sirstaug = SirstAugDataset(base_dir=sirstaug_base_dir, mode=mode)
        self.mdfa = MDFADataset(base_dir=mdfa_base_dir, mode=mode, base_size=base_size)

    def __getitem__(self, i):
        if i < self.mdfa.__len__():
            return self.mdfa.__getitem__(i)
        else:
            inx = i - self.mdfa.__len__()
            return self.sirstaug.__getitem__(inx)

    def __len__(self):
        return self.sirstaug.__len__() + self.mdfa.__len__()

    @property
    def name(self):
        return 'merged'
    

class MDFADataset(Data.Dataset):
    def __init__(self, base_dir='../data/MDFA', mode='train', base_size=256):
        assert mode in ['train', 'test']

        self.mode = mode
        if mode == 'train':
            self.img_dir = osp.join(base_dir, 'training')
            self.mask_dir = osp.join(base_dir, 'training')
        elif mode == 'test':
            self.img_dir = osp.join(base_dir, 'test_org')
            self.mask_dir = osp.join(base_dir, 'test_gt')
        else:
            raise NotImplementedError

        self.img_transform = transforms.Compose([
            transforms.Resize((base_size, base_size), interpolation=Image.BILINEAR),
            transforms.ToTensor(),
        ])
        self.mask_transform = transforms.Compose([
            transforms.Resize((base_size, base_size), interpolation=Image.NEAREST),
            transforms.ToTensor(),
        ])

    def __getitem__(self, i):
        if self.mode == 'train':
            img_path = osp.join(self.img_dir, '%06d_1.png' % i)
            mask_path = osp.join(self.mask_dir, '%06d_2.png' % i)
        elif self.mode == 'test':
            img_path = osp.join(self.img_dir, '%05d.png' % i)
            mask_path = osp.join(self.mask_dir, '%05d.png' % i)
        else:
            raise NotImplementedError

        img = Image.open(img_path).convert('L')
        mask = Image.open(mask_path).convert('L')

        img, mask = self.img_transform(img), self.mask_transform(mask)
        return img, mask

    def __len__(self):
        if self.mode == 'train':
            return 9978
        elif self.mode == 'test':
            return 100
        else:
            raise NotImplementedError
        
    @property
    def name(self):
        return 'mdfa'

class SirstAugDataset(Data.Dataset):
    def __init__(self, base_dir='../data/sirst_aug', mode='train', base_size=256):
        assert mode in ['train', 'test']

        if mode == 'train':
            self.data_dir = osp.join(base_dir, 'trainval')
        elif mode == 'test':
            self.data_dir = osp.join(base_dir, 'test')
        else:
            raise NotImplementedError

        self.names = []
        for filename in os.listdir(osp.join(self.data_dir, 'images')):
            if filename.endswith('png'):
                self.names.append(filename)

        self.img_transform = transforms.Compose([
            transforms.Resize((base_size, base_size), interpolation=Image.BILINEAR),
            transforms.ToTensor(),
        ])
        self.mask_transform = transforms.Compose([
            transforms.Resize((base_size, base_size), interpolation=Image.NEAREST),
            transforms.ToTensor(),
        ])


    def __getitem__(self, i):
        name = self.names[i]
        img_path = osp.join(self.data_dir, 'images', name)
        label_path = osp.join(self.data_dir, 'masks', name)

        img = Image.open(img_path).convert('L')
        mask = Image.open(label_path).convert('L')

        img, mask = self.img_transform(img), self.mask_transform(mask)
        return img, mask

    def __len__(self):
        return len(self.names)
    
    @property
    def name(self):
        return 'sirstaug'
    

class IRSTDDataset(Data.Dataset):
    def __init__(self, base_dir='./data/IRSTD-1k', mode='train', base_size=256):
        assert mode in ['train', 'test']

        if mode == 'train':
            with open(osp.join(base_dir, 'trainval.txt'), 'r') as f:
                self.names = f.readlines()
        elif mode == 'test':
            with open(osp.join(base_dir, 'test.txt'), 'r') as f:
                self.names = f.readlines()
        else:
            raise NotImplementedError
        self.mode = mode
        self.base_dir = base_dir
        self.names = [name.strip()+'.png' for name in self.names]

        self.img_transform = transforms.Compose([
            transforms.Resize((base_size, base_size), interpolation=Image.BILINEAR),
            transforms.ToTensor(),
        ])
        self.mask_transform = transforms.Compose([
            transforms.Resize((base_size, base_size), interpolation=Image.NEAREST),
            transforms.ToTensor(),
        ])


    def __getitem__(self, i):
        name = self.names[i]
        img_path = osp.join(self.base_dir, 'IRSTD1k_Img', name)
        label_path = osp.join(self.base_dir, 'IRSTD1k_Label', name)

        img = Image.open(img_path).convert('L')
        mask = Image.open(label_path).convert('L')

        img, mask = self.img_transform(img), self.mask_transform(mask)
        return img, mask

    @property
    def name(self):
        return 'IRSTD'

    def __len__(self):
        return len(self.names)