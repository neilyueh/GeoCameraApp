import os
import json
from PIL import Image, ImageDraw, ImageFont

def generate_placeholder_icon(size=(1024, 1024), text="Geo\nCamera"):
    """Generates a simple placeholder icon if no source image is provided."""
    img = Image.new('RGB', size, color=(20, 20, 30))
    d = ImageDraw.Draw(img)
    
    # Draw a circle (lens)
    center = (size[0] // 2, size[1] // 2)
    radius = size[0] // 3
    d.ellipse([center[0]-radius, center[1]-radius, center[0]+radius, center[1]+radius], 
              outline=(0, 255, 255), width=20)
    
    # Draw a pin shape (simplified) at the top right
    pin_color = (0, 255, 0)
    d.ellipse([size[0]-300, 100, size[0]-100, 300], fill=pin_color)
    d.polygon([(size[0]-200, 300), (size[0]-250, 450), (size[0]-150, 450)], fill=pin_color)

    return img

def create_icons(source_image_path, project_path):
    """
    Resizes the source image to all required iOS app icon sizes 
    and updates Contents.json.
    """
    
    # Defined sizes for iPhone (iOS 12+)
    # This list can be expanded for iPad, Watch, etc. but we focus on iPhone for now as per user request
    sizes = [
        (20, 1), (20, 2), (20, 3),
        (29, 1), (29, 2), (29, 3),
        (40, 1), (40, 2), (40, 3),
        (60, 2), (60, 3),
        (1024, 1) # App Store
    ]
    
    app_icon_set_path = os.path.join(project_path, "Assets.xcassets", "AppIcon.appiconset")
    if not os.path.exists(app_icon_set_path):
        os.makedirs(app_icon_set_path)
        
    images_json = []

    try:
        if source_image_path and os.path.exists(source_image_path):
            print(f"Loading source image from {source_image_path}")
            original_img = Image.open(source_image_path)
        else:
            print("Source image not found or not provided. Generating placeholder.")
            original_img = generate_placeholder_icon()
            # Save the placeholder as the source for reference
            original_img.save("generated_icon_1024.png")

        for point_size, scale in sizes:
            pixel_size = point_size * scale
            filename = f"Icon-{point_size}x{point_size}@{scale}x.png"
            
            # Resize
            img_resized = original_img.resize((pixel_size, pixel_size), Image.Resampling.LANCZOS)
            output_path = os.path.join(app_icon_set_path, filename)
            img_resized.save(output_path)
            
            images_json.append({
                "size": f"{point_size}x{point_size}",
                "idiom": "iphone",
                "filename": filename,
                "scale": f"{scale}x"
            })
            
            # Also add for "ios-marketing" (1024x1024)
            if point_size == 1024:
                 images_json.append({
                    "size": "1024x1024",
                    "idiom": "ios-marketing",
                    "filename": filename,
                    "scale": "1x"
                })

        # Clean duplicates from the list (1024 entry might cause duplicate if not handled, but logic above separates idiom)
        # Actually, let's restructure the json generation to be more precise based on Apple's spec spec
        
        final_json = {
            "images": [
                {"size": "20x20", "idiom": "iphone", "filename": "Icon-20x20@2x.png", "scale": "2x"},
                {"size": "20x20", "idiom": "iphone", "filename": "Icon-20x20@3x.png", "scale": "3x"},
                {"size": "29x29", "idiom": "iphone", "filename": "Icon-29x29@2x.png", "scale": "2x"},
                {"size": "29x29", "idiom": "iphone", "filename": "Icon-29x29@3x.png", "scale": "3x"},
                {"size": "40x40", "idiom": "iphone", "filename": "Icon-40x40@2x.png", "scale": "2x"},
                {"size": "40x40", "idiom": "iphone", "filename": "Icon-40x40@3x.png", "scale": "3x"},
                {"size": "60x60", "idiom": "iphone", "filename": "Icon-60x60@2x.png", "scale": "2x"},
                {"size": "60x60", "idiom": "iphone", "filename": "Icon-60x60@3x.png", "scale": "3x"},
                {"size": "1024x1024", "idiom": "ios-marketing", "filename": "Icon-1024x1024@1x.png", "scale": "1x"}
            ],
            "info": {
                "version": 1,
                "author": "xcode"
            }
        }
        
        # Write Contents.json
        with open(os.path.join(app_icon_set_path, "Contents.json"), "w") as f:
            json.dump(final_json, f, indent=2)
            
        print(f"Successfully generated app icons in {app_icon_set_path}")

    except Exception as e:
        print(f"Error generating icons: {e}")

if __name__ == "__main__":
    # Path to the Xcode project folder (containing Assets.xcassets)
    project_dir = "/Users/lenien-tzu/Documents/Nelson/TestPrj/GeoCameraApp/GeoCameraApp"
    
    # Try to find the generated image (if step 1 succeeded manually or we retry)
    # We'll assume the artifact logic might put it in the current dir or artifacts dir
    # For now, we will look for 'geo_camera_app_icon.png' in the current dir.
    # If not found, the script generates a placeholder.
    
    # Note: user might have the image from the generate_image tool saved as an artifact.
    # We need to know where generate_image saves files. Usually strictly to artifacts.
    # Let's check the artifacts dir.
    
    # Artifact directory is: /Users/lenien-tzu/.gemini/antigravity/brain/2cc31609-9fcd-4a3b-b9ca-dbbdc2faa524
    artifact_dir = "/Users/lenien-tzu/.gemini/antigravity/brain/2cc31609-9fcd-4a3b-b9ca-dbbdc2faa524"
    source_img = os.path.join(artifact_dir, "geo_camera_app_icon_1771064456538.png")
    
    create_icons(source_img, project_dir)
