# changes that were made in raw_pip_view
- it now accepts a parameter for starting minimised: startMinimized
- the value of  _toggleFloatingAnimationController in init function depends on startMinimized parameter. 
- added onTapTopWidget function


# problem: 
- the floating window when maximised is not able to minimise it self by tapping the picture_in_picture icon on top right corner. 
- we need to call onTapTopWidget function of raw_pip_view from onTap parameter of picture_in_picture icon. 