
# Communication

Vague praise like, "Great idea!" is not useful or desired.  If you believe a
proposal has specific value beyond any that I have already stated, *do* mention
it.  If you believe a proposal will create complications or costs that I have
not already stated, bring those up.  I will be happy to have potential problems
brought up, even if I already thought of them and dismissed them silently.

A little whimsy around the edges is just fine.  A good analogy is a thing of
beauty.  Don't lose any clarity while shooting for style, though.

# Programming

When writing one-off programs, prefer to write them in Perl, when there is no
compelling reason to chose another language.  I am Ricardo Signes (RJBS), and
most of my programming work is in Perl, so I will find it easiest to review.
Write the code as I would write it, drawing on my published work.  Assume that
you can use Perl v5.36.  Use subroutine signatures.

When writing new non-trivial routines, *do* provide documentation as seen in
surrounding code.

Do not add code comments restating what the line of code does.  For example,
never produce something like this:

    # Get the full path to the file in this directory.
    $path = "$directory/$filename";

Do add comments explaining particularly tricky algorithmns, or places where the
code has been intentionally made complex to work around a subtle problem.

When adding non-trivial comments to code, sign them as I would, in this format,
using the current date:

```
# This is the text of the comment. -- claude, YYYY-MM-DD
```

When editing or refactoring existing code, you **must not** remove comments
that were already there, unless they become irrelevant or inaccurate.

# Writing tests

Test cases should be expressed as calls to named helpers that takes all inputs
and expected outputs as arguments, with infrastructure (object construction,
wiring) hidden in the helper. The call site should read as a compact, scannable
declaration of what the case is, not a step-by-step procedure.

# Git habits

When committing to git, when you use your name in an author or co-author
credit, use the name "Claude".  Do not include a version or model name.  If you
are listing yourself as the author, do not *also* put yourself in a
Co-Authored-By trailer.  When listing someone else as the author, *do* put
yourself in a Co-Authored-By trailer.

Git commits should be geared toward the reader, meaning multiple smaller
commits, each moving from one state to the next, are to be preferred.

Commit work without being prompted.  If I don't like the work, I will ask you
to amend the commit.
