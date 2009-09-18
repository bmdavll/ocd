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

A single ``o`` will take you to the parent directory. It can be followed by
a count to indicate the number of levels. The default aliases allow you to
repeat the letter once for every level::

    o     # same as cd ..
    oo    # same as o 2 or cd ../..
    ooo   # same as o 3
          # etc.

You can also move into the children of a parent directory. If your directory
structure looked like this::

    /
    +---bin
    +---boot
    +---etc
    |   +---X11
    .
    +---home
    |   +---jimi
    .       +---bin
    .       +---music <= you are here
    +---usr
    .   +---share
    .

You can do ``o bin`` or ``ooo usr/share``. Tab completion will help you
navigate into directories as if you had already ``cd``'ed there.

Usually though, you can just do ``o usr/share``, since the function will try
``/home/jimi/usr/share``, ``/home/usr/share``, and finally ``/usr/share``,
until it finds a directory match.

Tab completion works similarly if you have "``set show-all-if-ambiguous on``"
in your ``.inputrc``. The first time you do ``o <TAB>``, it'll list only the
siblings of the current directory. A repeated ``<TAB>`` will list the
children of all parent directories.

The function will do prefix matching, so for example ``o et`` will change
your directory to ``/etc``.


``cl``
======

This command will try to ``cd`` to a sensible place based on your last
command, and then ``ls`` there.  For example, each of these commands
followed by ``cl`` will change your directory to the one named "``foo``"::

    ls /usr/share/foo
    sudo mount /dev/sdb1 /media/foo
    cp -a ~/foo .
    rm foo/bar.txt
    find foo -type f | cut -c 5-
    sort -u lines > foo/out

It does this by reading the last line from your ``$HISTFILE``, stripping
shell metacharacters from it, and then checking each argument in reverse
order. This requires that ``bash`` update the history file after each
command, so make sure "``history -a``" is part of your ``$PROMPT_COMMAND``.
Add this line to your ``.bashrc`` if it doesn't work::

    PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

You can also specifiy options to ``ls``::

    cl -lA


Install
=======

Source ``ocd.sh`` in ``bash`` to use these functions. To automatically do
this, add a line to your ``.bashrc``::

    .  /path/to/ocd.sh


Tips
====

* You can direct ``bash`` to skip adding these commands to the history file
  by setting ``HISTIGNORE`` in your ``.bashrc``::

      HISTIGNORE+=':cl:o'

  Or, if you have extended globbing turned on (``shopt -s extglob``)::

      HISTIGNORE+=':cl:o*(o)'

* To quickly go up one or more directory levels under the default key
  bindings, use ``o<C-o>``, ``oo<C-o>``, etc.

* You can bind ``cl`` to a key in your readline config (``.inputrc``)::

      "\C-g": "\C-a\C-kcl\C-m"  # bind cl to Ctrl-g
      # to bind to Alt-g instead, change "\C-g" to "\eg" or "M-g"

* Check out other ``cd`` utilities like rupa's j_ or joelthelion's autojump_.

.. _j: http://github.com/rupa/j
.. _autojump: http://github.com/joelthelion/autojump


Author
======

David Liang (bmdavll at gmail.com)

