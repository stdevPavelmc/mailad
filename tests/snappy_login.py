#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright, TimeoutError

def check_login(url, username, password, screenshot_path=None):
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            page = browser.new_page()

            try:
                page.goto(url, timeout=15000)
            except Exception as e:
                print(f"Connection failed: {str(e)}")
                return 2

            try:
                # Fill login form
                page.fill('input[name="Email"]', username)
                page.fill('input[name="Password"]', password)
                page.click('button[data-bind="command: SubmitCommand"]')

                # Wait for either error or success
                try:
                    page.wait_for_selector('div.alert:visible', timeout=3000)
                    error_text = page.inner_text('div.alert span[data-bind="text: submitError"]')
                    print(f"Login error: {error_text}")
                    
                    # Save screenshot if path provided
                    if screenshot_path:
                        Path(screenshot_path).parent.mkdir(parents=True, exist_ok=True)
                        page.screenshot(path=screenshot_path, full_page=True)
                        print(f"Screenshot saved to {screenshot_path}")
                    
                    # fail
                    return 1
                except TimeoutError:
                    # Wait for success element
                    page.wait_for_selector('#V-MailFolderList', timeout=5000)
                    
                    # Save screenshot if path provided
                    if screenshot_path:
                        Path(screenshot_path).parent.mkdir(parents=True, exist_ok=True)
                        page.screenshot(path=screenshot_path, full_page=True)
                        print(f"Screenshot saved to {screenshot_path}")
                    
                    # success
                    return 0

            except TimeoutError:
                print("Timeout waiting for page elements")
                return 3
            except Exception as e:
                print(f"Unexpected error: {str(e)}")
                return 3
            finally:
                browser.close()

    except Exception as e:
        print(f"Browser error: {str(e)}")
        return 3

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Snappy Mail Login Test with Screenshot')
    parser.add_argument('url', help='Login page URL')
    parser.add_argument('user', help='Username/Email')
    parser.add_argument('password', help='Password')
    parser.add_argument('screenshot_path', nargs='?', default=None, 
                      help='Optional path to save screenshot')
    
    args = parser.parse_args()
    
    exit_code = check_login(
        args.url,
        args.user,
        args.password,
        args.screenshot_path
    )

    sys.exit(exit_code)
