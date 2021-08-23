
@goal a
echo a

@goal b @private
echo b

@goal @glob 15_private.sh
echo $ITEM

@goal @glob 15_private.tush @private
echo $ITEM
