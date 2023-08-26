# PlanarTrack: A Large-scale Challenging Benchmark for Planar Object Tracking
🔮 This is the official evaluation toolkit for [PlanarTrack: A Large-scale Challenging Benchmark for Planar Object Tracking (ICCV 2023)](https://arxiv.org/abs/2303.07625).

[[`Paper`](https://arxiv.org/abs/2303.07625)] [[`Website`](https://hengfan2010.github.io/projects/PlanarTrack/)] [[`Benchmark-OneDrive (~107G)`](https://1drv.ms/u/s!AiNXDMvtaw5Jjg8Yjusmnybv3Slo?e=Fi0HS5)]

![PlanarTrack](https://github.com/HengLan/PlanarTrack/blob/main/asset/planar.png)

## Usage

- 👉 Download the repository, and unzip it to your computer
- 👉 Download the annotations ([GoogleDrive](https://drive.google.com/file/d/1nn_vzy3TKiK0XokGOVFb7pd5RLk7FTGS/view?usp=sharing) or [OneDrive](https://1drv.ms/u/s!AiNXDMvtaw5JjhHD48MYDWpKT_oJ?e=wduAFp)) of PlanarTrack, and unzip it to folder `PlanarTrack/annotation/`
- 👉 Download the tracking result file ([GoogleDrive](https://drive.google.com/file/d/1nfrzF302yfdH8tzS5ujs4u4JGikcVvxX/view?usp=sharing) or [OneDrive](https://1drv.ms/u/s!AiNXDMvtaw5JjhKFNwTS7qLgMqlA?e=WOOPDh)) of evaluated trackers, and unzip it to folder `PlanarTrack/tracking_result/`
- 🏃 Run `RunEvaluation.m` in Matlab, and the plots will be saved in `PlanarTrack/plots/`

## Citing PlanarTrack
🙏 If you use PlanarTrack for your research, please consider giving it a star :star: and citing it:

```
@inproceedings{liu2023planartrack,
        title={PlanarTrack: A Large-scale Challenging Benchmark for Planar Object Tracking},
        author={Liu, Xinran and Liu, Xiaoqiong and Yi, Ziruo and Zhou, Xin and Le, Thanh and
        Zhang, Libo and Huang, Yan and Yang, Qing and Fan, Heng},
        booktitle={ICCV},
        year={2023}
}
```

## Acknowledgment

🌹 We would like to thank [LaSOT](https://github.com/HengLan/LaSOT_Evaluation_Toolkit) and [POT-210](https://www3.cs.stonybrook.edu/~hling/data/POT-210/planar_benchmark.html) for sharing their codes.
