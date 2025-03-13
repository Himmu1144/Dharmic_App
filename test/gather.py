# import json
# import re

# def process_quotes_file(input_file, output_file):
#     quotes = []
#     current_quote = ""
#     current_author = ""
#     collecting_quote = False
#     collecting_author = False
    
#     with open(input_file, 'r', encoding='utf-8') as f:
#         for line in f:
#             line = line.strip()
            
#             # Skip comments and empty lines
#             if line.startswith('//') or not line:
#                 continue
                
#             # Look for quote pattern
#             if '"quote"' in line:
#                 quote_match = re.search(r'"quote"\s*:\s*"(.*?)"', line)
#                 if quote_match:
#                     current_quote = quote_match.group(1)
#                     # If the quote continues to next line
#                     if line.endswith('"') and not line.endswith('",'):
#                         collecting_quote = True
#                     else:
#                         collecting_quote = False
            
#             # Look for author pattern
#             elif '"author"' in line:
#                 author_match = re.search(r'"author"\s*:\s*"(.*?)"', line)
#                 if author_match:
#                     current_author = author_match.group(1)
#                     # If both quote and author are found, create a quote object
#                     if current_quote and current_author:
#                         author_img_name = current_author.lower().replace(' ', '_').replace(',', '').replace('.', '')
#                         quotes.append({
#                             "quote": current_quote,
#                             "language": "hi",
#                             "author": current_author,
#                             "author_img": f"assets/images/{author_img_name}.png"
#                         })
#                         current_quote = ""
#                         current_author = ""
            
#             # Handle collecting multiline quotes
#             elif collecting_quote:
#                 if line.endswith('"') or line.endswith('",'):
#                     current_quote += " " + line.strip('"').strip('",')
#                     collecting_quote = False
#                 else:
#                     current_quote += " " + line.strip('"')
    
#     # Write the processed quotes to the output file
#     with open(output_file, 'w', encoding='utf-8') as f:
#         json.dump(quotes, f, indent=4, ensure_ascii=False)
    
#     print(f"Successfully processed {len(quotes)} quotes and saved to {output_file}")
#     return quotes

# # Usage
# input_file = 'quotes_hin.json'
# output_file = 'quotes_hin_fixed.json'
# process_quotes_file(input_file, output_file)



# import json

# def extract_unique_authors(json_file_path):
#     try:
#         # Read the JSON file
#         with open(json_file_path, 'r', encoding='utf-8') as file:
#             quotes_data = json.load(file)
        
#         # Extract all author names
#         authors = set()
#         for quote in quotes_data:
#             if 'author' in quote and quote['author']:
#                 authors.add(quote['author'])
        
#         # Print the sorted list of unique authors
#         print(f"Found {len(authors)} unique authors:")
#         for i, author in enumerate(sorted(authors), 1):
#             print(f"{i}. {author}")
            
#         return sorted(list(authors))
    
#     except json.JSONDecodeError as e:
#         print(f"Error parsing JSON file: {e}")
#         return []
#     except FileNotFoundError:
#         print(f"File not found: {json_file_path}")
#         return []
#     except Exception as e:
#         print(f"An error occurred: {e}")
#         return []

# # Call the function with your file path
# if __name__ == "__main__":
#     file_path = "quotes_fixed.json"
#     extract_unique_authors(file_path)



# import json

# def add_tags_to_quotes(tags_file_path, quotes_file_path, output_file_path):
#     # Load the tag-author mapping
#     with open(tags_file_path, 'r', encoding='utf-8') as tags_file:
#         tags_data = json.load(tags_file)
    
#     # Create a dictionary for quick lookup: author -> tag
#     author_to_tag = {}
#     for tag_entry in tags_data:
#         tag = tag_entry["Tag"]
#         for author in tag_entry["authors"]:
#             author_to_tag[author] = tag
    
#     # Load the quotes
#     with open(quotes_file_path, 'r', encoding='utf-8') as quotes_file:
#         quotes_data = json.load(quotes_file)
    
#     # Count variables for statistics
#     total_quotes = len(quotes_data)
#     tagged_quotes = 0
#     untagged_quotes = 0
#     unknown_authors = set()
    
#     # Add tags to quotes based on author
#     for quote in quotes_data:
#         if "author" in quote and quote["author"]:
#             author = quote["author"]
#             if author in author_to_tag:
#                 quote["tag"] = author_to_tag[author]
#                 tagged_quotes += 1
#             else:
#                 # If author not found in mapping, set tag to "Other" or leave it untagged
#                 quote["tag"] = "Other"
#                 unknown_authors.add(author)
#                 untagged_quotes += 1
    
#     # Save the updated quotes to the output file
#     with open(output_file_path, 'w', encoding='utf-8') as output_file:
#         json.dump(quotes_data, output_file, indent=4, ensure_ascii=False)
    
#     # Print statistics
#     print(f"Total quotes processed: {total_quotes}")
#     print(f"Quotes tagged successfully: {tagged_quotes}")
#     print(f"Quotes with unknown authors: {untagged_quotes}")
    
#     if unknown_authors:
#         print("\nAuthors not found in tag mapping:")
#         for author in sorted(unknown_authors):
#             print(f"- \"{author}\"")
#         print("\nYou may want to add these authors to your tag mapping.")
    
#     print(f"\nUpdated quotes saved to {output_file_path}")

# if __name__ == "__main__":
#     # File paths - update these as needed
#     tags_file_path = "author_tags.json"  # Your JSON with tag-author mapping
#     quotes_file_path = "quotes_fixed.json"  # Your quotes file
#     output_file_path = "quotes_tagged.json"  # Where to save the tagged quotes
    
#     add_tags_to_quotes(tags_file_path, quotes_file_path, output_file_path)



# import json
# import os

# def update_author_img_paths(json_file_path, output_file_path=None):
#     """
#     Updates author_img paths to use the tag name instead of the author name.
    
#     Args:
#         json_file_path (str): Path to the input JSON file
#         output_file_path (str, optional): Path to save the updated JSON file. 
#                                           If None, the original file is overwritten.
#     """
#     if output_file_path is None:
#         output_file_path = json_file_path
    
#     # Read the JSON file
#     with open(json_file_path, 'r', encoding='utf-8') as file:
#         data = json.load(file)
    
#     # Track counts for statistics
#     total_items = len(data)
#     updated_items = 0
#     skipped_items = 0
    
#     # Update each item in the data
#     for item in data:
#         if "tag" in item and "author_img" in item:
#             # Extract the tag value and use it for the author_img path
#             tag = item["tag"]
#             if tag:
#                 # Create the new path using the tag instead of the author name
#                 item["author_img"] = f"assets/images/{tag}.png"
#                 updated_items += 1
#             else:
#                 skipped_items += 1
#         else:
#             skipped_items += 1
    
#     # Write the updated data back to the file
#     with open(output_file_path, 'w', encoding='utf-8') as file:
#         json.dump(data, file, indent=4, ensure_ascii=False)
    
#     # Print statistics
#     print(f"Processing completed!")
#     print(f"Total items: {total_items}")
#     print(f"Updated items: {updated_items}")
#     print(f"Skipped items: {skipped_items}")
#     print(f"Updated file saved to: {output_file_path}")

# if __name__ == "__main__":
#     # Path to your JSON file
#     json_file = "quotes_hin_tagged.json"
    
#     # Path for the output file (use None to overwrite the original)
#     output_file = "quotes_hin_updated.json"  
    
#     # Run the update function
#     update_author_img_paths(json_file, output_file)



# import json

# def add_tags_to_quotes(tags_file_path, quotes_file_path, output_file_path):
#     # Load the tag-author mapping
#     with open(tags_file_path, 'r', encoding='utf-8') as tags_file:
#         tags_data = json.load(tags_file)
    
#     # Create dictionaries for tag lookup
#     author_to_tag = {}
#     exact_match_tags = {}  # For authors whose name exactly matches a tag
    
#     # First, identify any tags that exactly match author names
#     for tag_entry in tags_data:
#         tag = tag_entry["Tag"]
#         for author in tag_entry["authors"]:
#             if author == tag:
#                 exact_match_tags[author] = tag
#             author_to_tag[author] = tag
    
#     # Load the quotes
#     with open(quotes_file_path, 'r', encoding='utf-8') as quotes_file:
#         quotes_data = json.load(quotes_file)
    
#     # Count variables for statistics
#     total_quotes = len(quotes_data)
#     tagged_quotes = 0
#     exact_match_tags_used = 0
#     general_tags_used = 0
#     untagged_quotes = 0
#     unknown_authors = set()
    
#     # Add tags to quotes based on author
#     for quote in quotes_data:
#         if "author" in quote and quote["author"]:
#             author = quote["author"]
            
#             # Check if this author has an exact match tag
#             if author in exact_match_tags:
#                 quote["tag"] = exact_match_tags[author]
#                 tagged_quotes += 1
#                 exact_match_tags_used += 1
#             # Otherwise use the general tag
#             elif author in author_to_tag:
#                 quote["tag"] = author_to_tag[author]
#                 tagged_quotes += 1
#                 general_tags_used += 1
#             else:
#                 # If author not found in mapping, set tag to "Other"
#                 quote["tag"] = "Other"
#                 unknown_authors.add(author)
#                 untagged_quotes += 1
    
#     # Save the updated quotes to the output file
#     with open(output_file_path, 'w', encoding='utf-8') as output_file:
#         json.dump(quotes_data, output_file, indent=4, ensure_ascii=False)
    
#     # Print statistics
#     print(f"Total quotes processed: {total_quotes}")
#     print(f"Quotes tagged successfully: {tagged_quotes}")
#     print(f"   - Using exact author-tag matches: {exact_match_tags_used}")
#     print(f"   - Using general category tags: {general_tags_used}")
#     print(f"Quotes with unknown authors (tagged as 'Other'): {untagged_quotes}")
    
#     if unknown_authors:
#         print("\nAuthors not found in tag mapping:")
#         for author in sorted(unknown_authors):
#             print(f"- \"{author}\"")
#         print("\nYou may want to add these authors to your tag mapping.")
    
#     print(f"\nUpdated quotes saved to {output_file_path}")

# if __name__ == "__main__":
#     # File paths - update these as needed
#     tags_file_path = "author_tags.json"  # Your JSON with tag-author mapping
#     quotes_file_path = "quotes_hin_fixed.json" # Your quotes file
#     output_file_path = "quotes_hin_tagged.json"  # Where to save the tagged quotes
    
#     add_tags_to_quotes(tags_file_path, quotes_file_path, output_file_path)



# import json
# import random

# def shuffle_quotes(input_file, output_file=None):
#     """
#     Reads a JSON file containing quotes, shuffles them, and writes them back.
    
#     Args:
#         input_file (str): Path to the input JSON file
#         output_file (str, optional): Path for the output file. If None, overwrites the input file.
#     """
#     if output_file is None:
#         output_file = input_file
    
#     try:
#         # Read the JSON file
#         with open(input_file, 'r', encoding='utf-8') as file:
#             quotes = json.load(file)
        
#         # Count the number of items before shuffling
#         original_count = len(quotes)
        
#         # Verify each item has a structure that makes sense
#         valid_quotes = []
#         incomplete_quotes = []
        
#         for quote in quotes:
#             # Check if it's a valid quote entry (has at least one of the key fields)
#             if isinstance(quote, dict) and any(key in quote for key in ['quote', 'author', 'tag']):
#                 valid_quotes.append(quote)
#             else:
#                 incomplete_quotes.append(quote)

#         # Shuffle only the valid quotes
#         random.shuffle(valid_quotes)
        
#         # Combine the valid (now shuffled) quotes with any incomplete quotes
#         shuffled_quotes = valid_quotes + incomplete_quotes
        
#         # Verify we didn't lose any quotes in the process
#         if len(shuffled_quotes) != original_count:
#             print(f"WARNING: Count mismatch! Original: {original_count}, New: {len(shuffled_quotes)}")
        
#         # Write the shuffled quotes back to file
#         with open(output_file, 'w', encoding='utf-8') as file:
#             json.dump(shuffled_quotes, file, indent=4, ensure_ascii=False)
        
#         print(f"Successfully shuffled {len(valid_quotes)} valid quotes!")
#         print(f"Found {len(incomplete_quotes)} items that didn't look like complete quotes")
#         print(f"Output saved to: {output_file}")
        
#     except json.JSONDecodeError as e:
#         print(f"Error: Invalid JSON in the input file: {e}")
#     except Exception as e:
#         print(f"An error occurred: {e}")

# if __name__ == "__main__":
#     # Configure these paths as needed
#     input_file = "quotes_updated.json"
#     output_file = "quotes_shuffled.json"  # Set to None to overwrite the input file
    
#     shuffle_quotes(input_file, output_file)


import os
import json
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin

def download_images_from_wiki():
    # Load the JSON file
    with open('assets/author.json', 'r') as file:
        authors = json.load(file)
    
    # Create images directory if it doesn't exist
    os.makedirs('assets/images', exist_ok=True)
    
    for author in authors:
        print(f"Processing {author['author']}...")
        wiki_url = author['author_link']
        image_path = author['author_img']
        
        # Extract just the filename from the path
        image_filename = os.path.basename(image_path)
        save_path = os.path.join('assets/images', image_filename)
        
        try:
            # Get the Wikipedia page
            response = requests.get(wiki_url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find the infobox image (typically the main profile image)
            infobox = soup.find('table', {'class': 'infobox'})
            if infobox:
                image_tag = infobox.find('img')
                
                if image_tag and 'src' in image_tag.attrs:
                    # Get the image URL and download it
                    img_url = image_tag['src']
                    if img_url.startswith('//'):
                        img_url = 'https:' + img_url
                    elif not img_url.startswith(('http://', 'https://')):
                        img_url = urljoin(wiki_url, img_url)
                    
                    print(f"Downloading image from {img_url}")
                    img_response = requests.get(img_url)
                    img_response.raise_for_status()
                    
                    # Save the image
                    with open(save_path, 'wb') as img_file:
                        img_file.write(img_response.content)
                    print(f"Saved to {save_path}")
                else:
                    print(f"No image found for {author['author']}")
            else:
                print(f"No infobox found for {author['author']}")
        
        except Exception as e:
            print(f"Error processing {author['author']}: {str(e)}")

if __name__ == "__main__":
    download_images_from_wiki()