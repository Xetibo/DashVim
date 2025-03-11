<div align = center>

![Logo of dashvim](./dashvim.png)

</div>

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

Note: If you wish to try DashVim out, you might want test the minimal configuration first. -> `nix run github:DashieTM/DashVim#minimal`.

# Keys

Could potentially be outdated.

## Space as leader

## Motion

| key     | Descpription         |
| ------- | -------------------- |
| j       | left                 |
| k       | down                 |
| l       | up                   |
| ;       | right                |
| \<A-j\> | window left          |
| \<A-k\> | window up            |
| \<A-l\> | window down          |
| \<A-;\> | window right         |
| \<A-f\> | open file tree (root |
| \<A-F\> | open file tree (cwd) |

## Debugging

| key          | Description       |
| ------------ | ----------------- |
| \<leader\>db | toggle breakpoint |
| \<leader\>dc | continue          |
| \<leader\>de | eval              |
| \<leader\>di | step into         |
| \<leader\>do | step over         |
| \<leader\>du | DAP UI            |

## neotest

| key          | Description          |
| ------------ | -------------------- |
| \<leader\>tf | execute files tests  |
| \<leader\>tn | execute nearest test |
| \<leader\>tN | debug nearest test   |
| \<leader\>ts | stop neotest         |

## buffer switching

| key | Description              |
| --- | ------------------------ |
| F1  | next buffer (cycles)     |
| F2  | previous buffer (cycles) |

## formatting

| key | Description      |
| --- | ---------------- |
| F4  | format this file |

## telescope

| key          | Description              |
| ------------ | ------------------------ |
| \<leader\>ff | find files               |
| \<leader\>fg | live ripgrep             |
| \<leader\>fh | help for functions etc   |
| \<leader\>fp | find projects            |
| \<leader\>fb | file browser             |
| \<leader\>b  | buffer browser           |
| \<leader\>ld | find LSP type definition |
| \<leader\>lw | find LSP symbol          |

### git

| key          | Description            |
| ------------ | ---------------------- |
| \<leader\>gq | show commits           |
| \<leader\>gw | show commits in branch |
| \<leader\>gb | show branches          |
| \<leader\>gb | git blame              |
| \<leader\>gs | show git status        |
| \<leader\>gd | Neogit diff            |
| \<leader\>gn | neogit                 |

### project telescope

<table> <tr> <th> normal mode </th> <th> insert mode </th></tr>
<tr> <td>

| key | Description                      |
| --- | -------------------------------- |
| d   | delete project                   |
| r   | rename project                   |
| c   | create project                   |
| s   | search files in project          |
| b   | browse files in project          |
| w   | change directory to project      |
| R   | recently opened files in project |
| f   | find file within project         |

</td> <td>

| key     | Description                      |
| ------- | -------------------------------- |
| \<C-d\> | delete project                   |
| \<C-v\> | rename project                   |
| \<C-a\> | create project                   |
| \<C-s\> | search files in project          |
| \<C-b\> | browse files in project          |
| \<C-l\> | change directory to project      |
| \<C-r\> | recently opened files in project |
| \<C-f\> | find file within project         |

</td> </tr> </table>

## cmp

Note, these require the cmp list view to be open to do anything!

| key         | Description                                              |
| ----------- | -------------------------------------------------------- |
| \<C-b\>     | scroll docs up                                           |
| \<C-f\>     | scroll docs down                                         |
| \<C-e\>     | cancel cmp                                               |
| Enter       | write selected suggestion (does nothing if not selected) |
| Tab         | scroll down through suggestion list                      |
| Shift + Tab | scroll up through suggestion list                        |

## LSP

| key           | Description               |
| ------------- | ------------------------- |
| \<leader\>ca  | go to definition          |
| \<leader\>cA  | go to declaration         |
| \<leader\>cs  | find references           |
| \<leader\>cd  | go to type definition     |
| \<leader\>cf  | go to implementation      |
| \<leader\>cq  | fix code action           |
| \<leader\>cQ  | refactor code action      |
| \<leader\>cw  | workspace symbol          |
| \<leader\>ce  | hover                     |
| \<leader\>cr  | rename                    |
| \<leader\>ct  | show errors and warnings  |
| \<leader\>cp  | go to previous diagnostic |
| \<leader\>cn  | go to next diagnostic     |
| \<leader\>ccr | restart LSP               |
| \<leader\>cld | line diagnostic toggle    |

## Flash

| key | Description                                           |
| --- | ----------------------------------------------------- |
| s   | followed by 2 other characters and the marker to jump |

## Dashboard

only available on dashboard

| key | Description         |
| --- | ------------------- |
| f   | file                |
| e   | new file            |
| p   | find project        |
| r   | recently used files |
| t   | find text           |
| c   | open yazi           |
| q   | quit                |

## Treesitter specials

used to interact with treesitter defined objects.

| key | Description                          |
| --- | ------------------------------------ |
| dif | Delete the content of a function     |
| daf | Delete the entire function           |
| dic | Delete the content of a class/struct |
| dac | Delete the entire class/struct       |
