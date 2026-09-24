#!/bin/sh
# Прив'язує сторінки сайту до останнього запушеного коміту шрифту Zaslav Display.
# jsDelivr кешує посилання @main до 12 годин, а посилання на конкретний коміт
# завжди віддає саме ті файли, тож після оновлення шрифту запустіть:
#   ./update-zaslav-font.sh            (шрифт у ~/Desktop/zaslav-font)
#   ./update-zaslav-font.sh шлях/до/zaslav-font
set -e
FONT_REPO="${1:-$HOME/Desktop/zaslav-font}"
cd "$(dirname "$0")"

git -C "$FONT_REPO" fetch -q origin
SHA=$(git -C "$FONT_REPO" rev-parse origin/main)
LOCAL=$(git -C "$FONT_REPO" rev-parse HEAD)
if [ "$SHA" != "$LOCAL" ]; then
  echo "У zaslav-font є незапушені зміни. Спершу зробіть там git push."
  exit 1
fi

perl -pi -e "s#zaslav-font\@[0-9A-Za-z]+/#zaslav-font\@$SHA/#g" fonts.html zaslav.html

if git diff --quiet -- fonts.html zaslav.html; then
  echo "Сайт уже використовує останню версію шрифту (${SHA%${SHA#???????}})."
  exit 0
fi

git add fonts.html zaslav.html
git commit -q -m "Pin Zaslav Display font to ${SHA%${SHA#???????}}"
git push -q
echo "Готово: сайт тепер бере шрифт з коміту ${SHA%${SHA#???????}}. GitHub Pages оновиться за хвилину-дві."
