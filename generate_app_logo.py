#!/usr/bin/env python3
"""
Generate AppLogo images - just the flower, no background (transparent)
"""

from PIL import Image
import os

SOURCE_ICON = "icon.png"
OUTPUT_DIR = "LookUpSilly/Assets.xcassets/AppLogo.imageset"

# Logo sizes for @1x, @2x, @3x
LOGO_SIZES = [
    (120, "AppLogo.png"),      # @1x
    (240, "AppLogo@2x.png"),   # @2x
    (360, "AppLogo@3x.png"),   # @3x
]

def create_logo_transparent(source_path, output_path, size):
    """Create logo with transparent background"""
    # Open source icon
    source = Image.open(source_path)
    
    # Convert to RGBA to preserve transparency
    if source.mode != 'RGBA':
        source = source.convert('RGBA')
    
    # Resize with high quality
    logo = source.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save as PNG with transparency
    logo.save(output_path, 'PNG')
    print(f"  ✓ Created {os.path.basename(output_path)} ({size}x{size})")

def main():
    print("🌼 Generating AppLogo with transparent background...")
    
    # Check if source exists
    if not os.path.exists(SOURCE_ICON):
        print(f"❌ Error: {SOURCE_ICON} not found")
        return
    
    # Create output directory if needed
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Generate all logo sizes
    for size, filename in LOGO_SIZES:
        output_path = os.path.join(OUTPUT_DIR, filename)
        create_logo_transparent(SOURCE_ICON, output_path, size)
    
    print("✅ AppLogo generated successfully!")
    print(f"📁 Logo saved to: {OUTPUT_DIR}")
    print("   (Transparent background - for use in app views)")

if __name__ == "__main__":
    main()

