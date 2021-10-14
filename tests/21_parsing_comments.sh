

@goal goal_with_comment # comment
@doc doc with comment # comment
  echo goal_with_comment

@goal test1
@doc 'doc   with   comment'        # comment
@depends_on goal_with_comment