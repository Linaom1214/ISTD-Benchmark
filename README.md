# IRSTD-Benchmark

[简体中文](./README-zh.md)

This repository is a benchmark tool for weak small target detection, aiming to provide a platform that integrates typical weak small target detection algorithms and unified evaluation metrics. This tool can help researchers and developers evaluate the performance of different algorithms on weak small target detection tasks.

## Features
- Provides standard evaluation metrics for weak small target detection to objectively evaluate algorithm performance, including but not limited to:
  - Precision-Recall
  - F1 score
- Simple and easy-to-use interface and sample code for users to quickly get started and integrate their own algorithms or conduct evaluation experiments.


| IRSTD1K                      | MDFA                          |
|------------------------------|-------------------------------|
| ![Image 1 Description](figs/IRSTD_roc.png) | ![Image 2 Description](figs/mdfa_roc.png) |

| Merged                        | SirstAUG                        |
|-------------------------------|---------------------------------|
| ![Image 3 Description](figs/merged_roc.png) | ![Image 4 Description](figs/sirstaug_roc.png) |


## Dataset

| Dataset      | Link |
| ----------- | ----------- |
| Sirst AUG      | [Link](https://github.com/Tianfang-Zhang/AGPCNet)       |
| MDFA   | [Link](https://github.com/wanghuanphd/MDvsFA_cGAN)        |
| IRSTD1K   | [Link](https://github.com/RuiZhang97/ISNet)        |

The above datasets have been organized and uploaded to Google Drive, and users can download and use them directly.

## Installation and Usage

## Install [Matlab Python API](https://ww2.mathworks.cn/help/matlab/matlab_external/install-the-matlab-engine-for-python.html)
```bash
pip install -r requirements.txt
```

## Usage
```bash
python method.py --dataset mdfa > mdfa.txt
                            irstd > istd1k.txt
                            sirstaug > sirstaug.txt
                            merged > merged.txt 
```

### Plot ROC curve

```bash 
python plot_curve.py
```

## Contribution

Contributions to this repository are welcome! If you have new algorithm implementations, improvements, or suggestions for other feature enhancements, please submit a pull request. We are happy to accept new contributions and continuously improve this tool.

## License

This tool is licensed under the [MIT License](LICENSE).

Please comply with the license when using this tool.
```