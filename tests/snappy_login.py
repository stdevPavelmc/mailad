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
                print(f"Connection failed: {str(e)}", flush=True)
                return 2

            # Check for existing session and logout if needed
            logged_in = 'div[id="V-MailFolderList"]'

            ## Only needed if a persistent cookies and all is set, not the case
            # logout = 'a[data-bind="click: logoutClick"]'
            # if page.is_visible(logged_in):
            #     print("Existing session detected. Logging out...", flush=True)
            #     page.click(logout)
            #     try:
            #         page.wait_for_selector('input[name="Email"]', timeout=5000)
            #     except TimeoutError:
            #         print("Reloading page to ensure login form is present...", flush=True)
            #         page.goto(url)
            #         page.wait_for_selector('input[name="Email"]', timeout=5000)

            try:
                # Fill login form
                page.fill('input[name="Email"]', username)
                page.fill('input[name="Password"]', password)
                page.click('button.buttonLogin')

                # Check for SUCCESS
                try:
                    page.wait_for_selector(logged_in, timeout=5000)
                    print(f"Successful login!", flush=True)
                    if screenshot_path:
                        page.screenshot(path=screenshot_path)
                        print(f"Screenshot saved", flush=True)
                    return 0
                except:
                    # Get error text from span tag
                    error_text = page.inner_text('span[data-bind="text: submitError"]').strip()
                    if error_text:
                        print(f"Login error: {error_text}", flush=True)
                        if screenshot_path:
                            page.screenshot(path=screenshot_path)
                            print(f"Screenshot saved", flush=True)
                        return 1
                    else:
                        print("Unable to get error text, but login failed", flush=True)
                        if screenshot_path:
                            page.screenshot(path=screenshot_path)
                            print(f"Screenshot saved", flush=True)
                        return 2

            except Exception as e:
                print(f"Unexpected error: {str(e)}", flush=True)
                if screenshot_path:
                    page.screenshot(path=screenshot_path)
                    print(f"Screenshot saved", flush=True)
                return 3
            finally:
                browser.close()

    except Exception as e:
        print(f"Browser error: {str(e)}", flush=True)
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
