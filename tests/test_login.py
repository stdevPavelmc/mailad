#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright, TimeoutError

# define the placeholders or the object and properties we need to detect on the go

## define DOM object detection for the integration
os_variables = {
    'email': 'input[name="Email"]',
    'password': 'input[name="Password"]',
    'submit': 'button.buttonLogin',
    'error_text': 'span[data-bind="text: submitError"]',
    'error_detail': 'div.alert p',
    'logged_in': 'div[id="V-MailFolderList"]'
}
or_variables = {
    'email': 'input[id="rcmloginuser"]',
    'password': 'input[id="rcmloginpwd"]',
    'submit': 'button[id="rcmloginsubmit"]',
    'error_text': '#messagestack div[role="alert"] span',
    'error_detail': '#messagestack div[role="alert"] span',
    'logged_in': 'div[id="folderlist-content"]'
}

def get_variables(snappy):
    if snappy:
        return os_variables
    else:
        return or_variables

def check_login(url, username, password, screenshot_path=None, snappy=False):
    # use one or another variables
    obj = get_variables(snappy)

    # do the magic, let's dance.
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
            try:
                # Fill login form
                page.fill(obj["email"], username)
                page.fill(obj["password"], password)
                page.click(obj["submit"])

                # Check for SUCCESS
                try:
                    page.wait_for_selector(obj["logged_in"], timeout=5000)
                    print(f"Successful login!", flush=True)
                    if screenshot_path:
                        if not snappy:
                            # Roundcube needs a delay to load emails, it's slow, yes
                            page.wait_for_timeout(3000)
                            # snappy needs to be fast to avoid the identity window ;)

                        page.screenshot(path=screenshot_path)
                        print(f"Screenshot saved", flush=True)
                    return 0
                except:
                    # Get error text from span tag
                    error_text = page.inner_text(obj["error_text"]).strip()
                    error_detail = ""
                    if snappy:
                        error_detail = page.inner_text(obj["error_detail"]).strip()
                    if error_text:
                        print(f"Login error: {error_text}, {error_detail}", flush=True)
                        if screenshot_path:
                            page.screenshot(path=screenshot_path)
                            print(f"Screenshot saved", flush=True)
                        return 1
                    else:
                        print("Unable to get error text, but login failed", flush=True)
                        if screenshot_path:
                            screenshot_dir = Path(screenshot_path).parent
                            mail_log_path = screenshot_dir / "mail.log"
                            try:
                                with open("/var/log/mail.log", "r") as f:
                                    with open(mail_log_path, "w") as w:
                                        w.write(f.read())
                                print(f"mail.log copied to {mail_log_path}", flush=True)
                            except Exception as e:
                                print(f"Failed to copy mail.log: {str(e)}", flush=True)

                            # take screnshot
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
    parser = argparse.ArgumentParser(description='Mail Login Test with Screenshot')
    parser.add_argument('-s', '--snappy',
                        action='store_true',
                        help='Use RoundCube by default, if passed -s, then use snappymail instead')
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
        args.screenshot_path,
        args.snappy
    )

    sys.exit(exit_code)
