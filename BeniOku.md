
# 🎮 FPGA Retro Oyun Konsolu (Tang Nano 9K)

**Sipeed Tang Nano 9K** FPGA geliştirme kartı üzerinde, tamamen **Verilog** donanım tanımlama dili kullanılarak tasarlanmış çok oyunlu bir retro konsol projesi.

Bu proje, herhangi bir işlemci (CPU), mikrodenetleyici veya hazır kütüphane **kullanmadan**, oyun mantığının, fizik motorlarının ve grafik oluşturma süreçlerinin doğrudan mantık kapıları (Logic Gates) ile nasıl oluşturulacağını gösterir.

![Proje Durumu](https://img.shields.io/badge/Durum-Tamamland%C4%B1-brightgreen) ![Dil](https://img.shields.io/badge/Dil-Verilog-blue) ![Donanım](https://img.shields.io/badge/Donan%C4%B1m-Gowin_GW1NR--9C-orange)

## 📖 Proje Özeti

Bu proje, standart bir FPGA kartını 4.3 inç LCD ekranı süren tam fonksiyonlu bir oyun konsoluna dönüştürür. Temel felsefesi **"Sıfır Yazılım"**dır; ekrana çizilen her piksel, hesaplanan her çarpışma ve yapay zeka kararları donanım seviyesinde (RTL) sentezlenmiştir.

İçerisinde menü sistemiyle geçiş yapılabilen 4 adet klasik atari oyunu bulunur.

## 📷 Oyunlardan Kareler

|                         🏓 Pong                          |                          🐍 Snake                          |
| :------------------------------------------------------: | :--------------------------------------------------------: |
| <img src="Image/Pong.jpeg" width="400" alt="Pong Oyunu"> | <img src="Image/Snake.jpeg" width="400" alt="Snake Oyunu"> |
|            **Yapay Zeka Rakip & Çift Oyuncu**            |           **Hızlanan Oynanış & Kuyruk Yönetimi**           |

|                             🐦 Flappy Bird                             |                          👻 Pac-Man                           |
| :--------------------------------------------------------------------: | :-----------------------------------------------------------: |
| <img src="Image/Flappy Bird.jpeg" width="400" alt="Flappy Bird Oyunu"> | <img src="Image/Pac-Man.jpeg" width="400" alt="Pacman Oyunu"> |
|                   **Fizik Motoru & Zıplama Kuyruğu**                   |          **3 Akıllı Hayalet & Prosedürel Labirent**           |
|                                                                        |                                                               |

## 📂 Dosya Yapısı

Proje dosyalarına aşağıdaki listeden doğrudan tıklayarak ulaşabilirsiniz:

<pre>
src/
├── <a href="src/TOP.v"><em>TOP.v</em></a>              # Ana Modül (Oyun Seçici & Sinyal Yönlendirme)
├── <a href="src/VGAMod.v"><em>VGAMod.v</em></a>           # VGA Sürücüsü & Görüntü Oluşturma
├── <a href="src/pong_logic.v"><em>pong_logic.v</em></a>       # Oyun Mantığı: Pong
├── <a href="src/snake_logic.v"><em>snake_logic.v</em></a>      # Oyun Mantığı: Snake
├── <a href="src/flappy_logic.v"><em>flappy_logic.v</em></a>     # Oyun Mantığı: Flappy Bird
├── <a href="src/pacman_logic.v"><em>pacman_logic.v</em></a>     # Oyun Mantığı: Pac-Man
├── <a href="src/Debounce.v"><em>Debounce.v</em></a>         # Buton Parazit Engelleyici
└── <a href="src/gowin_rpll/gowin_rpll.v"><em>gowin_rpll.v</em></a>       # PLL IP Core (27MHz -> 9MHz)
</pre>

## 🏗️ Donanım Mimarisi

Tasarım, **Oyun Mantığı (Logic)** ile **Görüntü Oluşturma (Renderer)** modüllerinin birbirinden ayrıldığı modüler bir yapıya sahiptir.

```mermaid
graph TD
    CLK[27MHz Kristal] --> PLL[rPLL IP Core]
    PLL -->|9 MHz Piksel Saati| TOP
    
    BTN[Fiziksel Butonlar] --> DEB[Debounce Modülü]
    DEB --> TOP[TOP Modül / Oyun Seçici]
    
    TOP --> PONG[Pong Logic]
    TOP --> SNAKE[Snake Logic]
    TOP --> FLAPPY[Flappy Bird Logic]
    TOP --> PACMAN[Pac-Man Logic]
    
    PONG --> MUX[Sinyal Birleştirici]
    SNAKE --> MUX
    FLAPPY --> MUX
    PACMAN --> MUX
    
    MUX --> VGA[VGA Renderer Mod]
    VGA --> LCD[4.3 inç LCD Ekran]
````

## 🔍 Kaynak Kod Analizi

Her bir Verilog modülünün ne işe yaradığına dair teknik detaylar:

### 1. Sistem ve Kontrol Modülleri

- <a href="src/TOP.v"><em>TOP.v</em></a> (Ana Modül):**
    
    - **Görevi:** Sistemin beynidir. Tüm alt modülleri birbirine bağlar.
        
    - **İşlevi:** "Oyun Seçici" durum makinesini (State Machine) barındırır. İki butona aynı anda 2 saniye basıldığında `game_mode` yazmacını değiştirerek oyunlar arasında geçiş yapar.
        
- <a href="src/Debounce.v"><em>Debounce.v</em></a> :**
    
    - **Görevi:** Sinyal temizleyici.
        
    - **İşlevi:** Mekanik butonlara basıldığında oluşan elektriksel gürültüyü (bouncing) filtreler. Sinyalin ~30ms boyunca kararlı kalmasını bekler, böylece oyunlarda hatalı çift tıklamaları engeller.
        
- <a href="src/gowin_rpll/gowin_rpll.v"><em>gowin_rpll.v</em></a>:**
    
    - **Görevi:** Saat frekansı yöneticisi.
        
    - **İşlevi:** Kart üzerindeki 27MHz kristal osilatör sinyalini alır ve 4.3 inç ekranın zamanlamasına uygun olan **9 MHz** hızına düşürür.
        

### 2. Grafik Motoru

- <a href="src/VGAMod.v"><em>VGAMod.v</em></a>:**
    
    - **Görevi:** Ressam (Prosedürel Render Motoru).
        
    - **İşlevi:** Görüntüleri hafızadan (RAM) okumak yerine, o an taranan pikselin koordinatına (`draw_x`, `draw_y`) göre rengi **matematiksel olarak anlık hesaplar**.
        
    - **Katmanlama (Layering):** Hangi nesnenin önde görüneceğine karar veren bir öncelik (priority) sistemi kullanır. (Örn: _Yazı > Oyuncu > Arka Plan_).
        
    - **Font Çizimi:** Sayıları ve "GAME OVER" yazılarını çizmek için bit haritalı (bitmap) bir font tablosu içerir.
        

### 3. Oyun Mantık Modülleri

- <a href="src/pong_logic.v"><em>pong_logic.v</em></a>:**
    
    - Basit kutu çarpışma (AABB) algılaması kullanır.
        
    - **Yapay Zeka:** Rakip raket, topun Y koordinatını sürekli takip edecek şekilde kodlanmıştır.
        
- <a href="src/snake_logic.v"><em>snake_logic.v</em></a>:**
    
    - **Hafıza:** Yılanın geçmiş hareketlerini saklamak için register dizileri (`reg [5:0] body_x [0:63]`) kullanır.
        
    - **RNG:** Elma konumlarını rastgele belirlemek için **Linear Feedback Shift Register (LFSR)** algoritmasını kullanır.
        
- <a href="src/flappy_logic.v"><em>flappy_logic.v</em></a>:**
    
    - **Fizik:** İşaretli (signed) aritmetik kullanarak hız ve ivme hesaplar (`velocity <= velocity + gravity`).
        
    - **Giriş Tamponu:** Fizik motoru ile buton basma anı arasındaki senkronizasyonu sağlamak için "Jump Queue" (Zıplama Kuyruğu) kullanır. Bu sayede hiçbir tuş basımı kaçırılmaz.
        
- <a href="src/pacman_logic.v"><em>pacman_logic.v</em></a>:**
    
    - **Harita:** Labirent duvarlarını resim olarak değil, bir koordinat fonksiyonu (`check_wall`) olarak matematiksel tanımlar.
        
    - **Yapay Zeka:**
        
        - _Kırmızı Hayalet:_ Oyuncunun konumuna göre vektör hesaplayıp en kısa yolu seçmeye çalışır (Targeting).
            
        - _Diğer Hayaletler:_ Yarı-rastgele hareket ederler.
            

## 🛠️ Donanım Kurulumu

- **FPGA Kartı:** Sipeed Tang Nano 9K (Gowin GW1NR-9C)
    
- **Ekran:** 4.3 inç RGB Arayüzlü LCD (40-pin)
    
- **Bağlantı:** LCD doğrudan kart üzerindeki FPC konnektörüne takılır.
    

## 🎮 Kontroller

Konsol sadece 2 buton (S1 ve S2) ile kontrol edilir.

|**İşlem**|**S1 Butonu (Sol)**|**S2 Butonu (Sağ)**|
|---|---|---|
|**Oyun Değiştirme**|**S1 + S2 (2 Saniye Basılı Tut)**|**S1 + S2 (2 Saniye Basılı Tut)**|
|**Pong**|Raketi Aşağı İndir|Raketi Yukarı Kaldır|
|**Snake**|Sola Dön|Sağa Dön|
|**Flappy Bird**|Zıpla|Zıpla|
|**Pac-Man**|Sola Dön|Sağa Dön|

## 🚀 Nasıl Yüklenir?

1. **Gowin EDA** yazılımını indirin ve kurun.
    
2. Proje dosyasını açın.
    
3. **"Process"** sekmesinden önce **"Synthesize"**, ardından **"Place & Route"** işlemlerini çalıştırın.
    
4. **Gowin Programmer**'ı açın.
    
5. Oyunun güç kesilince silinmemesi için **"Embedded Flash Mode"** seçeneğini kullanın.
    
6. **"Program/Configure"** butonuna basarak yükleyin.

---

Geliştirici: Salih Tekin Ayvacı