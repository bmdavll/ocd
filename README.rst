==========
``ocd.sh``
==========

-----------------------------
``cd`` functions for ``bash``
-----------------------------


``o``
=====

This command takes you out of your current directory, similar to these
common aliases, but with additional functionality::

    alias ..='cd ..'
    alias ...='cd ../..'
    # etc.

A single ``o`` will take you to the parent directory. It can be followed by a
count to indicate the number of levels to go up. The default aliases allow
you to repeat the letter once for each additional level. For example::

    o -P  # same as cd -P ..
    oo    # same as o 2 or cd ../..
    ooo   # same as o 3 or cd ../../..
    oooo  # same as o 4

You can also move into the children of a parent directory with the same
command. If your directory structure looked like this::

    /
    +---bin
    +---boot
    +---etc
    |   +---X11
    +---home
    |   +---jimi
    |       +---bin
    |       +---music -> /home/jimi/foo/bar
    |           ^--- YOU ARE HERE
    |
    |       +---foo
    |           +---bar
    |           +---tmp
    |       +---tmp
    +---usr
    .   +---share
    .

You can use ``o bin`` or ``ooo usr/share`` to go to ``~/bin`` or ``/usr/share``,
respectively. Tab completion will help you navigate into directories as if
you had already ``cd``'ed there.

Usually though, you can simply do ``o usr/share``, since the function will try
``/home/jimi/usr/share``, ``/home/usr/share``, and finally ``/usr/share``, until
it finds a matching directory.

Tab completion works similarly if you have "``set show-all-if-ambiguous on``"
in your ``.inputrc``. The first time you enter ``o <TAB>``, it'll list only the
siblings of the current directory. A repeated ``<TAB>`` will list the children
of all parent directories.

The function will do prefix matching, so for example ``o et`` will change your
directory to ``/etc``. If there are multiple matches within the first parent
directory to contain matches, you will be prompted to select one. At the
prompt, you can enter something non-numeric (a space for example) to go on
to search in higher-level directectories, or send the EOF character to
cancel selection.

Resolution of symlinks is handled by ``cd`` in the default way (i.e. dot-dot
logically), unless an option to ``cd`` is given::

    # starting in ~/music
    o tmp       # cd to ~/tmp
    o -P tmp    # cd to ~/foo/tmp


``cdl``
=======

This command will try to ``cd`` to a sensible place based on your last
command, and then ``ls`` there. For example, each of these commands followed
by ``cdl`` will change your directory to the one named "``foo``"::

    ls foo
    sudo mount /dev/sdb1 /media/foo
    cp -a ~/foo .
    rm foo/bar.txt
    find foo -type f | sort
    sort -u lines > foo/out

This is accomplished by retrieving the last command line from history,
stripping shell metacharacters from it, and then checking each argument in
reverse order for directories. You can also specifiy options to ``ls``::

    cdl -lA


Install
=======

Source ``ocd.sh`` in ``bash`` to use these functions. To automatically do
this, add a line to your ``.bashrc``::

    .  /path/to/ocd.sh


Tips
====

* You can direct ``bash`` to skip adding these commands to the history file
  by setting ``HISTIGNORE`` in your ``.bashrc``::

      HISTIGNORE='cdl:o'

  Or, if you have extended globbing turned on (``shopt -s extglob``)::

      HISTIGNORE='cdl:o*(o)'

* You can bind ``cdl`` to a key in your readline config (``.inputrc``)::

      "\C-g": "\C-a\C-kcdl\C-m"     # bind cdl to Ctrl-g
      # to bind to Alt-g instead, change "\C-g" to "\eg" or "M-g"


Author
======

David Liang (bmdavll at gmail.com)

