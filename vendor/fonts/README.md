These fonts were added to make the Linux build use the same font assets as the original Windows setup.

Sources used for this branch:
- `msmincho.ttc`: `https://github.com/edubkendo/.dotfiles/raw/refs/heads/master/.fonts/msmincho.ttc`
- `PMingLiU.ttf`: `https://github.com/ntu-student-congress/tortue/raw/refs/heads/master/fonts/PMingLiU.ttf`
- `times.ttf`, `timesbd.ttf`, `timesi.ttf`, `timesbi.ttf`: copied from `https://github.com/misuchiru03/font-times-new-roman`

The Times New Roman files are stored under the standard Windows basenames because the compiler looks for those names when resolving exact font files on Linux.
`PMingLiU.ttf` is vendored as a fallback CJK font for glyphs not covered by the main MS Mincho setup.
