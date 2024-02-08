import board
import digitalio
from PIL import Image, ImageDraw, ImageFont
import adafruit_ssd1306
import subprocess
import textwrap

# Create the I2C interface.
i2c = board.I2C()

# Create the SSD1306 OLED class.
oled = adafruit_ssd1306.SSD1306_I2C(128, 64, i2c, addr=0x3D)

# Clear the display.
oled.fill(0)
oled.show()

# Create blank image for drawing.
width = oled.width
height = oled.height
image = Image.new('1', (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Define constants for text display.
padding = -2
top = padding
x = 0

# Load default font.
font = ImageFont.load_default()

# Calculate the width and height of a character drawn with the font.
char_width, char_height = font.getsize('A')

# Define the update_display function to include text wrapping.
def update_display(text):
    # Clear the display image.
    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    
    # Wrap the text and draw it on the display.
    for i, line in enumerate(textwrap.wrap(text, width // char_width)):
        # Stop if there's no more room on the display.
        if i * char_height >= height:
            break
        # Draw the text line by line.
        draw.text((x, top + i * char_height), line, font=font, fill=255)
    
    # Display the image.
    oled.image(image)
    oled.show()
# Command to execute the stream program
command = "make -j stream && ./stream -m models/ggml-tiny.en.bin --step 4000 --length 8000 -c 0 -t 4 -ac 1024"

# Start the subprocess and redirect stdout and stderr
process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

# Loop to read the subprocess output line by line
while True:
    line = process.stdout.readline()
    if not line:
        break  # If no more output, break the loop
    print(line)  # For debugging: print the line to the console
    update_display(line.strip())  # Update the display with the current line

# Clean up
process.stdout.close()
process.wait()
