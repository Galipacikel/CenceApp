#!/bin/bash

# Git Push Script - Her değişiklikten sonra otomatik push
# Kullanım: ./git_push.sh "commit mesajı"

set -e  # Hata durumunda script'i durdur

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Commit mesajını al
COMMIT_MESSAGE="${1:-Auto commit: $(date '+%Y-%m-%d %H:%M:%S')}"

echo -e "${BLUE}🚀 Git Push Script Başlatılıyor...${NC}"
echo -e "${YELLOW}📝 Commit Mesajı: $COMMIT_MESSAGE${NC}"

# Git durumunu kontrol et
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Bu dizin bir Git repository değil!${NC}"
    exit 1
fi

# Değişiklikleri kontrol et
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}ℹ️  Commit edilecek değişiklik bulunamadı.${NC}"
else
    echo -e "${GREEN}📁 Değişiklikler tespit edildi, commit yapılıyor...${NC}"
    
    # Tüm değişiklikleri stage'e al
    git add .
    
    # Commit yap
    git commit -m "$COMMIT_MESSAGE"
    
    echo -e "${GREEN}✅ Commit başarılı!${NC}"
fi

# Remote repository kontrolü - ali remote'unu kullan
if git remote get-url ali > /dev/null 2>&1; then
    echo -e "${GREEN}🌐 Ali remote repository bulundu, push yapılıyor...${NC}"
    
    # Push yap
    if git push ali main 2>/dev/null || git push ali master 2>/dev/null; then
        echo -e "${GREEN}🎉 Push başarılı!${NC}"
    else
        echo -e "${RED}❌ Push başarısız! Manuel olarak kontrol edin.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Remote repository bulunamadı. Sadece local commit yapıldı.${NC}"
    echo -e "${BLUE}💡 Remote eklemek için: git remote add origin <repository-url>${NC}"
fi

echo -e "${GREEN}🏁 İşlem tamamlandı!${NC}"