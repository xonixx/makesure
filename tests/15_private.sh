
@goal a
echo a

@goal b @private
echo b

@goal_glob 15_private.sh
echo $ITEM

@goal_glob 15_private.tush @private
echo $ITEM
