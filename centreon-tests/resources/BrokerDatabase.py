from robot.libraries.BuiltIn import BuiltIn
from Common import find_in_log
import time

def do_when_catch_in_log(log: str, date, content, func, arg):
    start = time.time()
    while True:
        time.sleep(1)
        if time.time() - start >= 5 * 60:
            break
        if find_in_log(log, date, content):
            return BuiltIn().run_keyword(func, arg)
    return False

def catch_in_log(log: str, date, content):
    start = time.time()
    while True:
        time.sleep(1)
        if time.time() - start >= 5 * 60:
            break
        if find_in_log(log, date, content):
            return True
    return False