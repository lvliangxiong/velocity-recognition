# clear.py
# clear the trabish files
import os
import shutil


VIDEO_FILTER = ['.mp4', '.wmv', '.rmvb', '.avi', '.mov',
                '.mpg', '.mpeg', '.dat', '.rm', '.asf']
PHOTO_FILTER = ['.gif', '.jpg', '.png',
                '.bmp', '.jpeg', '.tiff', '.pcd', '.svg']
OTHERS = ['.py', '.ass', '.rar', 'zip', 'txt']


def listdir(path, level=0):
    """List all the files and folders in the path

    Args:
        path (str): pathname
        level (int, optional): path depth, for formatting output. Defaults to 0.
    """
    for i in os.listdir(path):
        subpath = os.path.join(path, i)
        print('*' * (level + 1) + i)
        if os.path.isdir(subpath):
            listdir(level + 1, subpath)


def clear(file_filter, path):
    """Clear files according to the file_filter

    Args:
        file_filter (list): a list of file extensions you want to keep
        path (str): path needed clearing
    """
    print('clearing')
    count = 0
    for i in os.walk(path):
        # print(i)
        for f in i[2]:  # for each file under the path
            for ff in file_filter:
                if ff.lower() == os.path.splitext(f)[1].lower():
                    break
            else:  # for file without strs in filefilter in its name
                absf = os.path.join(i[0], f)
                print('remove file %s' % absf)
                os.remove(absf)
                count = count + 1
    if(count > 0):
        print(f"{count} {'file' if count == 1 else 'files'} cleared")
    else:
        print('nothing needs to clear')
    print('done')


def clearemptydir(abspath):
    if not os.path.isabs(abspath):
        print('Need absolute path')
        return 0
    count = 0
    for i in os.walk(abspath):
        if i[1] or i[2]:
            continue
        else:
            print('removing empty dir %s' % i[0])
            shutil.rmtree(i[0])
            count += 1
    if count:
        clearemptydir(abspath)


if __name__ == "__main__":

    f = ['.tif', '.jpg', '.py', '.m', '.mat',
         '.hdev', '.png', '.txt', '.MOV', '.dat']
    clear(f, os.getcwd())

    imgs = os.listdir("images")
    for index, img in enumerate(imgs):
        print(img)
        os.renames("images/" + img, "images/" + "test_" + "0" *
                   (0 if index >= 100 else (1 if index >= 10 else 2)) + str(index) + ".tif")
