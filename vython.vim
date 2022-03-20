if has('python3')

let $PYPLUGPATH .= expand('<sfile>:p:h') "used to import .py files from plugin directory

command! Vython normal :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr><c-w><c-h>
nnoremap <silent> <F10> :vsp<enter><c-w><c-l>:e ~/pythonbuff.py<cr>:call Vythonload()<cr><c-w><c-h>

nnoremap <silent> <F5> mPggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>
inoremap <silent> <F5> <esc>mPggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>a
vnoremap <silent> <F5> mP<esc>ggVG"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>

nnoremap <silent> <s-enter> mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>
inoremap <silent> <s-enter> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>a
vnoremap <silent> <s-enter> mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>
"alternate mappings for terminal/ssh usage
    nnoremap <silent> <c-\> mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
    inoremap <silent> <c-\> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`Pa
    vnoremap <silent> <c-\> mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 exec(filtcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>`P
"hy support
    "nnoremap <silent> <c-]> mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 hyexec(hyfiltcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>
    "inoremap <silent> <c-]> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 hyexec(hyfiltcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>a
    "vnoremap <silent> <c-]> mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 hyexec(hyfiltcode())<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>
    nnoremap <silent> <c-]> mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 hy.eval( hy.read_str(hyfiltcode()) )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>
    inoremap <silent> <c-]> <esc>mPV"py:py3 mout.output()<cr>:redir @b<cr>:py3 hy.eval( hy.read_str(hyfiltcode()) )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>a
    vnoremap <silent> <c-]> mP"py:py3 mout.output()<cr>:redir @b<cr>:py3 hy.eval( hy.read_str(hyfiltcode()) )<cr>:redir END<cr>:py3 mout.smartprint(vim.eval("@b"))<cr>

nnoremap <silent> <c-b> mPV"py:py3 mout.printexp()<cr>
inoremap <silent> <c-b> <esc>mPV"py:py3 mout.printexp()<cr>a
vnoremap <silent> <c-b> mP"py:py3 mout.printexp()<cr>
    nnoremap <silent> <m-b> mPV"py:py3 mout.printexp()<cr>
    inoremap <silent> <m-b> <esc>mPV"py:py3 mout.printexp()<cr>a
    vnoremap <silent> <m-b> mP"py:py3 mout.printexp()<cr>

inoremap <c-u> <C-R>=Pycomplete()<CR>

func! Pycomplete()
    py3 vim.command("call complete(col(\'.\'), " + repr(get_completions()) + ')')
    return ''
endfunc
 
func! Vythonload() 
py3 << EOL
import vim
import sys
import os
import re
import threading
import numpy as np
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

try:
    import hy
    #def hyexec(scode):
    #    print('exec',scode)
    #    return hy.eval(hy.read_str(scode))
except:
    class blank: pass
    hy = blank()
    def _dumfun(*args, **kwargs): pass
    hy.read_Str = _dumfun
    hy.eval = _dumfun
    print('hy not installed')

try:
    from coconut.convenience import parse as cocparse
except:
    def cocparse(strin):
        return strin


#work-around for Python3.7/tensorflow
if not hasattr(vim, 'find_module'):
    def _dumfun(*args, **kwargs): pass
    vim.find_module = _dumfun

sys.argv = ['']
sys.path.append('.') #might be needed to import from current directory
sys.path.append(os.environ['PYPLUGPATH']) # might be needed to import from plugin directory
#on Windows, this is needed for qt stuff like pyplot
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = sys.exec_prefix.replace('\\','/') + '/Library/plugins/platforms'

if os.getcwd().lower() == 'C:\\WINDOWS\\system32'.lower():
    os.chdir(os.path.expanduser('~'))


def filtcode():
    mout.removeindent()
    code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
    if 'fconv' in globals():
        code = [q if q.strip()[0]!='!' else fconv(q) for q in code]
    else:
        code = [q for q in code if q and len(q.strip())>0 and q.strip()[0]!='!']
    return cocparse('\n'.join(code))

def hyfiltcode():
    #mout.removeindent()
    code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
    return '(do ' + '\n'.join(code) + ' )'

class outputter():
    def __init__(vyself):
        vyself.linecount = 1
        vyself.pybuf = vim.current.buffer
        vyself.pywin = vim.current.window
        vyself.oldlinecount = 0

    def output(vyself):
        vyself.pybuf.append('')
        vyself.pybuf.append('# In [' + str(vyself.linecount) + ']:')
        z = [q for q in vim.eval("@p").split('\n') if len(q)>0]
        [vyself.pybuf.append(l) for l in z]
        numlines = len(z)
        vyself.linecount += 1
        if numlines > 9:
            thiswin = vim.current.window
            for win in vim.current.tabpage.windows:
                if 'pythonbuff' in win.buffer.name:
                    vim.current.window = win
                    vim.command('normal G' + str(numlines-3)+'kV' +str(numlines-5)+'jzf')
            vim.current.window = thiswin
        thiswin = vim.current.window
        #if thiswin is vyself.pywin:
        #    vim.command('normal gv"ox')

        vyself.scrollbuffend()
        vim.command('normal zz')


    def mprint(vyself, *args, **kwargs):
        if 'sep' in kwargs.keys():
            sep = kwargs['sep']
        else:
            sep = ' '
        newlinecount = vyself.linecount-1
        outstr = ''
        for a in args:
            outstr += str(a) + sep
        if outstr:
            outstr = outstr[:-len(sep)]
        if newlinecount != vyself.oldlinecount:
            vyself.pybuf.append('') 
            vyself.pybuf.append('# Out [' + str(newlinecount) + ']:') 
        [vyself.pybuf.append(s) for s in outstr.split('\n')] 
        vyself.oldlinecount = vyself.linecount-1
        vyself.scrollbuffend()

    #only prints string that has content (for displaying Python execution results)
    def smartprint(vyself, stringtoprint):
        procstr = stringtoprint.split('\n')
        for dumindex in range(4):
            for line in procstr:
                if not line:
                    procstr.remove('')
                else:
                    break
        if procstr:
            vyself.mprint('\n'.join(procstr))

    def printexp(vyself):
        vyself.pybuf.append('') 
        lines = vim.eval("@p").strip().split('\n')
        for thisline in lines:
            thisexp = thisline.split('=')[0]
            try:
                if thisexp[-1] in '+-*/':
                    thisexp = thisexp[:-1]
                    if thisexp[-1] == '*':
                        thisexp = thisexp[:-1]
                expout = thisexp.strip() + ' = ' + repr(eval(thisexp))
                [vyself.pybuf.append(exp) for exp in expout.split('\n')] 
            except:
                try:
                    thisexp = thisline.replace('\n','')
                    expout = thisexp + ' = ' + repr(eval(thisexp))
                    [vyself.pybuf.append(exp) for exp in expout.split('\n')] 
                except:
                    [vyself.pybuf.append(thisexp.split('=')[0].strip() + " is not defined.")] 
            vyself.scrollbuffend()

    def scrollbuffend(vyself):
        thiswin = vim.current.window
        for win in vim.current.tabpage.windows:
            if 'pythonbuff' in win.buffer.name:
                vim.current.window = win
                vim.command('normal G')
        vim.current.window = thiswin

    def readtable(vyself,delim=' +'):
        try:
            table = vim.eval("@p")
            q = [re.split(delim, l) for l in table.split('\n') if len(l)>0]
            vyself.table = [[eval(y) for y in l if len(y)>0] for l in q] 
            return vyself.table
        except:
            pass

    def removeindent(vyself):
        code = vim.eval("@p").split('\n')
        code = [line for line in code if len(line)>0]
        minindent = 500
        for line in code:
            spaces = re.search('^ +' , line)
            if spaces:
                indent = len(spaces.group())
                if indent < minindent:
                    minindent = indent
            else:
                minindent = 0
                break
        code = '\n'.join([line[minindent:] for line in code])
        code = code.replace('\\', '\\\\')
        code = code.replace('\'', '\\\'')
        code = code.replace('\"', '\\\"')
        vim.command('let @p="' + code + '"')

def print(*args, **kwargs):
    mout.mprint(*args, **kwargs)
    vim.command('redraw')

mout = outputter()

def vimdebug():
    vim.debug = sys._getframe().f_back
    if '<module>' not in vim.debug.f_code.co_name:
        vim.oldglobals = list(globals().keys())
        for k in vim.debug.f_locals.keys():
            globals()[k] = vim.debug.f_locals[k]
        try:
            globals()['self_'] = vyself
        except:
            pass
    else:
        vim.oldglobals = None
    vim.command('normal ' + str(vim.debug.f_lineno) + 'gg')
    raise Exception('Debugging in "' + vim.debug.f_code.co_name + '" at line number   ' 
                        + str(vim.debug.f_lineno) )

def endvimdebug():
    if vim.oldglobals:
        gkeys = list(globals().keys())
        for k in gkeys:
            if k not in vim.oldglobals:
                globals().pop(k)

try:
    from completer import IPCompleter # requires IPython; will use simpler rlcompleter if not available
    def get_completions():
        completer = IPCompleter(namespace=locals(),global_namespace=globals())
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        token = thisline[:oldcursposx]
        token = re.split(';| |:|~|%|,|\+|-|\*|/|&|\||\(|\)=',token)[-1]
        completions= [token] + completer.all_completions(token)
        thistoken = token
        replaceline = thisline[:(oldcursposx-len(thistoken))] + thisline[(oldcursposx):]
        vim.current.line = replaceline
        newpos = (oldcursposy, oldcursposx-len(thistoken))
        vim.current.window.cursor = newpos
        return completions
except:
    print('loading rlcompleter')
    import rlcompleter
    def get_completions():
        rlcmpltr = rlcompleter.Completer()
        oldcursposy, oldcursposx = vim.current.window.cursor
        thisline = vim.current.line
        token = thisline[:oldcursposx][::-1]
        if token[:2] == "'[":
            token = token[2:]
            getkeys = True
        else:
            getkeys = False
        try:
            stop = re.search('[^A-Za-z0-9_.]', token).start()
        except:
            stop = None
        thistoken = token[:stop][::-1]
        completions = [thistoken]
        if getkeys:
            try:
                completions += list( eval(thistoken + '.keys()') )
                completions = completions[1:]
                completions = [c +"']" for c in completions]
            except:
                pass
        else:
            cindex = 0
            comp = rlcmpltr.complete(thistoken,cindex)
            while comp != None:
                completions.append(comp)
                cindex += 1
                comp = rlcmpltr.complete(thistoken,cindex)
            try:
                completions += dir(eval(thistoken))
                completions = list(set(completions))
            except:
                pass
            replaceline = thisline[:(oldcursposx-len(thistoken))] + thisline[(oldcursposx):]
            vim.current.line = replaceline
            newpos = (oldcursposy, oldcursposx-len(thistoken))
            vim.current.window.cursor = newpos
        return completions

def runfile(filename):
    with open(filename) as f:
        exec(f.read())
    temp = locals()
    for k in temp.keys():
        globals()[k] = temp[k]

def runfbackg(filename):
    t = threading.Thread(target=runfile, args=(filename,))
    t.start()

EOL
endfunc "end Vythonload

endif "end if has("python3")
            
