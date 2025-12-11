#!/usr/bin/env python3
"""
Script to convert logo.jpg to different PNG sizes for web icons
Run this script to generate the required icon sizes for your web app
"""

from PIL import Image
import os

def convert_logo():
    # Paths
    logo_path = "../assets/images/logo.jpg"
    web_icons_dir = "../web/icons"
    
    # Create icons directory if it doesn't exist
    os.makedirs(web_icons_dir, exist_ok=True)
    
    try:
        # Open the logo
        with Image.open(logo_path) as img:
            # Convert to RGBA if not already
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Define sizes needed
            sizes = [
                (16, "../web/favicon.png"),
                (192, "../web/icons/Icon-192.png"),
                (512, "../web/icons/Icon-512.png"),
                (192, "../web/icons/Icon-maskable-192.png"),
                (512, "../web/icons/Icon-maskable-512.png")
            ]
            
            for size, output_path in sizes:
                # Resize image
                resized = img.resize((size, size), Image.Resampling.LANCZOS)
                
                # For maskable icons, add padding
                if "maskable" in output_path:
                    # Create a new image with padding for maskable icons
                    padded_size = int(size * 0.8)  # 80% of the size for safe area
                    padding = (size - padded_size) // 2
                    
                    padded_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
                    resized_for_padding = img.resize((padded_size, padded_size), Image.Resampling.LANCZOS)
                    padded_img.paste(resized_for_padding, (padding, padding))
                    resized = padded_img
                
                # Save the resized image
                resized.save(output_path, "PNG", optimize=True)
                print(f"Created: {output_path} ({size}x{size})")
        
        print("✅ Logo conversion completed successfully!")
        print("All web icons have been generated from your logo.")
        
    except FileNotFoundError:
        print("❌ Error: logo.jpg not found in assets/images/")
        print("Please make sure your logo file exists at: assets/images/logo.jpg")
    except Exception as e:
        print(f"❌ Error converting logo: {e}")

if __name__ == "__main__":
    convert_logo()