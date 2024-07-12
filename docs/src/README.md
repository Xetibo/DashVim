![Screenshot](./docs/screenshot.png)

A Neovim configuration made with [nvf](https://github.com/NotAShelf/nvf)

# Installation

Can either be done as a NixOS or home-manager module.

```nix
programs.dashvim = {
    enable = true;
    colorscheme = config.conf.colorscheme;
    # other options
};
```

## Try before Installation

`nix run` inside the directory, or `nix run github:DashieTM/DashVim`.

Note: If you wish to try DashVim out, you might want test the minimal configuration first.  -> `nix run github:DashieTM/DashVim#minimal`.

# Keys
Could potentially be outdated.

## Space as leader

## Motion
| key     | Descpription              |
| ------- | ------------------------- |
| j       | left                      |
| k       | down                      |
| l       | up                        | 
| ;       | right                     |
| \<A-j\> | window left               |
| \<A-k\> | window up                 |
| \<A-l\> | window down               |
| \<A-;\> | window right              |
| \<A-f\> | open file tree (root      |
| \<A-F\> | open file tree (cwd)      |


## Debugging
| key         | Description           |
| ----------- | --------------------- |
| \<leader\>da  | run with args         |
| \<leader\>db  | toggle breakpoint     |
| \<leader\>dB  | breakpoint condition  |
| \<leader\>dC  | run to cursoor        |
| \<leader\>dc  | continue              |
| \<leader\>de  | eval                  |
| \<leader\>dg  | go to line            |
| \<leader\>di  | step into             |
| \<leader\>k   | down                  |
| \<leader\>l   | up                    |
| \<leader\>;   | run last              |
| \<leader\>dO  | step over             |
| \<leader\>do  | step out              |
| \<leader\>dp  | pause                 |
| \<leader\>dr  | toggle repl           |
| \<leader\>ds  | session               |
| \<leader\>dt  | terminate             |
| \<leader\>du  | DAP UI                |
| \<leader\>dw  | widgets               |

## neotest
| key         | Description               |
| ----------- | ------------------------- |
| \<leader\>tt  | execute all tests         |
| \<leader\>tT  | execute nearest test      |

## buffer switching
| key | Description               |
| --- | ------------------------- |
| F1  | next buffer (cycles)      |
| F2  | previous buffer (cycles)  |

## formatting
| key | Description               |
| --- | ------------------------- |
| F4  | format this file          |

## telescope
| key         | Description               |
| ----------- | ------------------------- |
| \<leader\>ff  | find files                |
| \<leader\>fg  | live ripgrep              |
| \<leader\>fh  | help for functions etc    |
| \<leader\>fp  | find projects             |
| \<leader\>fb  | file browser              |
| \<leader\>b  | buffer browser           |

### telescope git
| key        | Description               |
| ---------- | ------------------------- |
| \<leader\>gq | show commits              |
| \<leader\>gw | show commits with diff    |
| \<leader\>gb | show branches             | 
| \<leader\>gr | show git status           |
| \<leader\>ga | show git stash            | 
| \<leader\>ge | git file tree             | 

### project telescope
<table> <tr> <th> normal mode </th> <th> insert mode </th></tr>
<tr> <td>

| key | Description                       |
| --- | --------------------------------- |
|  d  | delete project                    |
|  r  | rename project                    |
|  c  | create project                    |
|  s  | search files in project           |
|  b  | browse files in project           |
|  w  | change directory to project       |
|  R  | recently opened files in project  |
|  f  | find file within project          |
</td> <td>

| key      | Description                       |
| -------- | --------------------------------- |
| \<C-d\>    | delete project                    |
| \<C-v\>    | rename project                    |
| \<C-a\>    | create project                    |
| \<C-s\>    | search files in project           |
| \<C-b\>    | browse files in project           |
| \<C-l\>    | change directory to project       |
| \<C-r\>    | recently opened files in project  |
| \<C-f\>    | find file within project          |

</td> </tr> </table>


## toggletrouble
| key        | Description               |
| ---------- | ------------------------- |
| \<leader\>t  | show errors and warnings  |

## cmp
Note, these require the cmp list view to be open to do anything!
| key         | Description                                               |
| ----------- | --------------------------------------------------------- |
| \<C-b\>       | scroll docs up                                            |
| \<C-f\>       | scroll docs down                                          |
| \<C-e\>       | cancel cmp                                                |
| Enter       | write selected suggestion (does nothing if not selected)  |
| Tab         | scroll down through suggestion list                       |
| Shift + Tab | scroll up through suggestion list                         |

## LSP 
| key          |  Description           |
| ------------ | ---------------------- |
|  \<leader\>ca  | go to definition       |
|  \<leader\>ca  | go to declaration      |
|  \<leader\>cs  | find references        |
|  \<leader\>cd  | go to type definition  |
|  \<leader\>cf  | go to implementation   |
|  \<leader\>cq  | fix code action        |
|  \<leader\>cQ  | refactor code action   |
|  \<leader\>cw  | signature help         |
|  \<leader\>ce  | hover                  |
|  \<leader\>cr  | rename                 |

## snippets
These require you to be inside a snippet!
| key      | Description               |
| -------- | ------------------------- |
| \<C-j\>    | jump to next entry        |
| \<C-k\>    | jump to previous entry    |

## Leap
| key      | Description                                            |
| -------- | ------------------------------------------------------ |
| s        | followed by 2 other characters and the marker to jump  |

## Dashboard
only available on dashboard
| key | Description               |
| --- | ------------------------- |
|  f  | file                      |
|  e  | new file                  |
|  p  | find project              |
|  r  | recently used files       |
|  t  | find text                 |
|  c  | open config               |
|  q  | quit                      |

## Treesitter specials
used to interact with treesitter defined objects.
| key | Description                          |
| --- | ------------------------------------ |
| dif | Delete the content of a function     |
| daf | Delete the entire function           |
| dic | Delete the content of a class/struct |
| dac | Delete the entire class/struct       |

Thanks to:
- [raf](https://github.com/NotAShelf) and friends for nvf :)
- [Nix-Artwork](https://github.com/NixOS/nixos-artwork/tree/master/logo) for the Nix/NixOS logo (Tim Cuthbertson (@timbertson))
