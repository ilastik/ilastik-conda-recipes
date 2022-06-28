# fiji-ilastik-helper recipe

With ImageJ, ilastik and the ilastik4ij plugin being installable via conda,
we want to enable running the ilastik installation from the env via the
Fiji plugin a flawless experience.

This tiny helper library sets the executable location of ilastik
to the conda environment when starting ImageJ. That way users don't have to
configure anything.

Supplies the `ImageJ_withIlastik` entrypoint.
