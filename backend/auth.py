# auth.py
import firebase_admin
from firebase_admin import credentials, auth
from fastapi import Request, HTTPException

# 1. Adımda indirdiğin anahtar dosyasının adını buraya yazıyorsun
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)

def verify_token(request: Request):
    """
    iOS'tan gelen isteğin Header kısmındaki bileti kontrol eder.
    Gerçek bir kullanıcıysa onun Firebase UID'sini döner.
    """
    auth_header = request.headers.get("Authorization")
    
    # Bilet yoksa veya formatı yanlışsa reddet
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Yetkilendirme bileti bulunamadı.")

    token = auth_header.split("Bearer ")[1]
    
    try:
        # Firebase'e soruyoruz: "Bu bilet geçerli mi?"
        decoded_token = auth.verify_id_token(token)
        return decoded_token['uid'] # Kullanıcının eşsiz harf/rakam ID'si (Örn: 'xYz123')
    except Exception as e:
        raise HTTPException(status_code=401, detail="Geçersiz veya süresi dolmuş bilet.")