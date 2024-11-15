from PIL import Image, ImageDraw, ImageFont
import os
characters = ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ", "ン"]
font_path = "ZenMaruGothic.ttf"  # 필기체 폰트 경로
name = "ZenMaruGothic"
output_dir = "images"

font = ImageFont.truetype(font_path, size=64)

for char in characters:
    # 텍스트 크기 계산
    dummy_img = Image.new("RGB", (1, 1))
    draw = ImageDraw.Draw(dummy_img)
    bbox = draw.textbbox((0, 0), char, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # 폰트의 ascent와 descent 값
    ascent, descent = font.getmetrics()
    total_height = ascent + descent

    # 이미지 크기 설정 (텍스트 크기 + 여유 공간)
    padding = 20
    img_width = text_width + padding
    img_height = total_height + padding

    # 새 이미지 생성 (흰색 배경)
    img = Image.new("RGB", (img_width, img_height), color="white")
    draw = ImageDraw.Draw(img)

    # 텍스트 위치 계산 (가운데 정렬)
    x = (img_width - text_width) // 2
    y = (img_height - total_height) // 2 + (ascent - text_height) // 2

    # 텍스트 그리기 (검은색)
    draw.text((x, y), char, font=font, fill="black")

    # 출력 폴더 생성 및 이미지 저장
    os.makedirs(f"{output_dir}/{char}", exist_ok=True)
    img.save(f"{output_dir}/{char}/{name}.png")
