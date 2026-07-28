# 09 - Text to ASL (Metinden İşaret Diline Çeviri) Mimarisi

## Amaç
Bu belgenin amacı, kullanıcının serbest metin kutusuna girdiği bir cümlenin (Örn: "Hello John, how are you?") nasıl parçalanıp, sözlükte aranıp, uygun videolar bulunarak ardışık bir video oynatma sırasına (Playlist) dönüştürüldüğünü anlatmaktır.

## İçindekiler
1. Çeviri Mantığı (Genel Bakış)
2. Tokenization (Kelimelere Ayırma ve Temizleme)
3. Dictionary Lookup (Sözlük Araması)
4. Unknown Words ve Finger Spelling (Bilinmeyen Kelimeler ve Harf Harf Kodlama)
5. Playlist Generation (Video Sırası Oluşturma)
6. Video Sequencing (Kesintisiz Oynatma)
7. Hata Yönetimi (Error Handling)
8. Gelecek Geliştirmeler (Future Improvements)
9. Özet
10. AI Implementation Notes

---

## 1. Çeviri Mantığı (Genel Bakış)
Uygulama Google Çeviri gibi yapay zekalı bir dil oluşturucu DEĞİLDİR. Kelime bazlı bir sözlük eşleştiricisidir. Cümle kelimelere bölünür, her kelimenin R2 / Cache video karşılığı bulunur ve bu videolar sırayla oynatılır.

---

## 2. Tokenization (Kelimelere Ayırma ve Temizleme)
Kullanıcının girdiği metin doğrudan işlenemez. Önce temizlenmelidir (Normalization).
* **Girdi:** "Hello! I am John."
* **Temizleme:** Noktalama işaretleri silinir ve tüm metin küçük harfe çevrilir. -> "hello i am john"
* **Tokenization:** Boşluklardan ayrılarak kelime dizisine (Array/List) çevrilir. -> `['hello', 'i', 'am', 'john']`

---

## 3. Dictionary Lookup (Sözlük Araması)
Token dizisindeki her bir kelime sırayla SQLite veritabanına sorulur:
`SELECT video_url FROM dictionary WHERE word = 'hello'`
* 'hello' bulundu -> URL listeye eklenir.
* 'i' bulundu -> URL listeye eklenir.
* 'am' bulundu -> URL listeye eklenir.

---

## 4. Unknown Words ve Finger Spelling (Harf Harf Kodlama)
Eğer kullanıcının yazdığı isim ("john") sözlükte (SQLite veritabanı) bulunamazsa ne olur?
İşaret dilinde (ASL), özel isimler veya bilinmeyen kelimeler harf harf (Finger-spelling) gösterilir.
* 'john' sözlükte yok.
* Kelime harflerine parçalanır -> `['j', 'o', 'h', 'n']`
* Veritabanında alfabe videoları (A-Z) mevcuttur. 
* Çıktı listesine `j.mp4`, `o.mp4`, `h.mp4`, `n.mp4` eklenir.

---

## 5. Playlist Generation (Video Sırası Oluşturma)
Tüm işlemler bittikten sonra Flutter arayüzüne (UI) aşağıdaki gibi sıralı bir URL/File listesi döndürülür:
```text
1. https://.../hello.mp4
2. https://.../i.mp4
3. https://.../am.mp4
4. https://.../j.mp4
5. https://.../o.mp4
6. https://.../h.mp4
7. https://.../n.mp4
```

---

## 6. Video Sequencing (Kesintisiz Oynatma)
En zor kısımdır. Eğer videolar arası geçişte ekran siyah olursa deneyim bozulur.
* Flutter'da tek bir `VideoPlayerController` yerine, aktif oynayan ve sıradaki (preload edilen) videoları yöneten bir algoritma (veya çift Controller yapısı) kurulmalıdır.
* İlk video bitince (`addListener` ile sonlandığı yakalandığında), hemen ikinci videonun (Cache Manager tarafından zaten cihazda olan) controller'ı ekrana bağlanır ve `play()` metodu çağırılır.

---

## 7. Hata Yönetimi (Error Handling)
* **İnternet Yok & Cache Boş:** Bir videonun interneti yoksa ve henüz cache edilmediyse, o kelime atlanarak (veya ekranda "[İnternet Yok]" uyarısı gösterilerek) bir sonraki videoya geçilir.
* **Gereksiz Bağlaçlar:** ASL gramerinde (am, is, are, the, a) gibi bağlaçlar kullanılmaz (ASL yapısı İngilizce'den farklıdır). İstenirse bu "Stop words" (durdurma kelimeleri) tokenization aşamasında filtrelenerek yok sayılabilir.

---

## 8. Gelecek Geliştirmeler (Future Improvements)
(Bu aşama bitirme projesine çok puan kazandırabilir).
Gelecekte Python destekli bir NLP (Doğal Dil İşleme) API'si kurularak, İngilizce "I am going to the store" cümlesi doğrudan ASL gramerine ("STORE I GO") çevrilebilir ve veritabanı bu yeni sıraya göre oynatılabilir.

---

## Özet
Text-to-ASL yapısı, kelimeleri eşleştirme ve bulunamayan kelimeleri alfabe harfleriyle telafi etme sistemine dayanır. Bu sistemin kalbinde, pürüzsüz (siyah ekrana düşmeyen) video geçişleri yatar.

---

## AI IMPLEMENTATION NOTES
* Tokenization algorithm: Strip punctuation -> lowercase -> split by space.
* Stop words list (optional): Filter out ["a", "an", "the", "am", "is", "are"] for better ASL grammar logic before looking up.
* Fallback logic: If `word` NOT IN SQLite, loop through `word.split('')` and append individual alphabet video URLs.
* Video playback sequence: Use a state manager to track `currentIndex`. On `VideoPlayerController` completion, increment `currentIndex` and initialize the next `File`.
