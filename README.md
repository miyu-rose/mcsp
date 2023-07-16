# mcsp
MACS LOADER/PLAYER for X680x0

・再生環境を選ぶ、低機能な MACS ローダ/プレイヤです。  
　ロード中のプログレスバーもございません。  

・060turbo.sys / HIMEM.SYS / TS16DRV / TS16DRVp による  
　ローカルメモリ / ハイメモリへ分割なしの一括 _READ によって  
　高速なローディングを実現しておりますが、以下の条件がございます。  

　[XEiJ + HFS上のファイル]  
　そのまま再生可（Mercury Unit 非対応）  

　[XM6 TypeG v3.35以降 + Windrv リモートドライブ上のファイル]  
　そのまま再生可  

　[XM6 TypeG v3.34以前 + Windrv リモートドライブ上のファイル]  
　正常再生不可（メインメモリ破壊の恐れアリ）  

　[SCSIドライブ上のファイル]  
　たんぼ(TNB製作所) さまの TS16FILE.x 常駐で再生可  
　（但しSCSIドライブは読み込み速度的に実用的ではないかも）  

　[PhantomX v1.02c以前 + PXVDISK ドライブ上のファイル]  
　正常再生不可　（危険ですので試さないでください）

　[PhantomX v1.03a以降 + PXVDISK ドライブ上のファイル]  
　そのまま再生可  
