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
                print(f"Connection failed: {str(e)}", flush=True)  # <-- FLUSH
                return 2

            # Check for existing session and logout if needed
            logout_selector = 'a[data-bind="click: logoutClick"]'
            if page.is_visible(logout_selector):
                print("Existing session detected. Logging out...", flush=True)  # <-- FLUSH
                page.click(logout_selector)
                try:
                    page.wait_for_selector('input[name="Email"]', timeout=5000)
                except TimeoutError:
                    print("Reloading page to ensure login form is present...", flush=True)  # <-- FLUSH
                    page.goto(url)
                    page.wait_for_selector('input[name="Email"]', timeout=5000)

            try:
                # Fill login form
                page.fill('input[name="Email"]', username)
                page.fill('input[name="Password"]', password)
                page.click('button.buttonLogin')

                # Wait for error alert to appearm if it does
                page.wait_for_selector('div.alert:visible', timeout=3000)
                
                # Get error text from span
                error_text = page.inner_text('div.alert span[data-bind="text: submitError"]').strip()
                
                if error_text:
                    print(f"Login error: {error_text}", flush=True)
                    if screenshot_path:
                        page.screenshot(path=screenshot_path)
                        print(f"Screenshot saved", flush=True)
                    return 1

                # No error alert found - check for SUCCESS
                if (page.wait_for_selector('#V-MailFolderList', timeout=5000)):
                    print(f"Successful login!", flush=True)
                    if screenshot_path:
                        page.screenshot(path=screenshot_path)
                        print(f"Screenshot saved", flush=True)
                    return 0

            except Exception as e:
                print(f"Unexpected error: {str(e)}", flush=True)  # <-- FLUSH
                return 3
            finally:
                browser.close()

    except Exception as e:
        print(f"Browser error: {str(e)}", flush=True)  # <-- FLUSH
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
