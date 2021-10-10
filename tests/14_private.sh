
@goal a
echo a

@goal b @private
echo b

@goal @glob 14_private.sh
echo $ITEM

@goal @glob 14_private.tush @private
echo $ITEM
