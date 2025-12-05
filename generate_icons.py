#!/usr/bin/env python3
"""
Generate iOS app icons with warm green pastel background and margins
"""

from PIL import Image
import os

# Warm green pastel color (adjust to preference)
BACKGROUND_COLOR = (168, 198, 160)  # Warm sage green pastel

SOURCE_ICON = "icon.png"
OUTPUT_DIR = "LookUpSilly/Assets.xcassets/AppIcon.appiconset"

# Icon sizes needed for iOS
ICON_SIZES = [
    (40, "icon-20@2x.png"),
    (60, "icon-20@3x.png"),
    (58, "icon-29@2x.png"),
    (87, "icon-29@3x.png"),
    (80, "icon-40@2x.png"),
    (120, "icon-40@3x.png"),
    (120, "icon-60@2x.png"),
    (180, "icon-60@3x.png"),
    (1024, "icon-1024.png"),
]

def create_icon_with_background(source_path, output_path, size, margin_percent=15):
    """Create icon with background color and margins"""
    # Open source icon
    source = Image.open(source_path)
    
    # Convert to RGBA if not already
    if source.mode != 'RGBA':
        source = source.convert('RGBA')
    
    # Calculate icon size with margin (use 85% of canvas for icon, 15% total margin)
    icon_size = int(size * (1 - margin_percent / 100))
    
    # Resize source icon
    source_resized = source.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    
    # Create canvas with background color
    canvas = Image.new('RGB', (size, size), BACKGROUND_COLOR)
    
    # Calculate position to center the icon
    x = (size - icon_size) // 2
    y = (size - icon_size) // 2
    
    # Paste icon onto canvas (handling transparency)
    canvas.paste(source_resized, (x, y), source_resized if source_resized.mode == 'RGBA' else None)
    
    # Save as PNG
    canvas.save(output_path, 'PNG')
    print(f"  ✓ Created {os.path.basename(output_path)} ({size}x{size})")

def main():
    print("🎨 Generating app icons with warm green pastel background...")
    
    # Check if source exists
    if not os.path.exists(SOURCE_ICON):
        print(f"❌ Error: {SOURCE_ICON} not found")
        return
    
    # Create output directory if needed
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Generate all icon sizes
    for size, filename in ICON_SIZES:
        output_path = os.path.join(OUTPUT_DIR, filename)
        create_icon_with_background(SOURCE_ICON, output_path, size)
    
    print("✅ All app icons generated successfully!")
    print(f"📁 Icons saved to: {OUTPUT_DIR}")

if __name__ == "__main__":
    main()

