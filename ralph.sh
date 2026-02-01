#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

for ((i=1; i<=$1; i++)); do
  echo "Iteration $i"
  echo "----------------------------------------"

  result=$(claude -p "$(cat PROMPT.md)" --output-format text)

  echo "$result"

  if [[ "$result" == *"<promises>COMPLETE</promises>"* ]]; then
    echo "All tasks complete after $i iterations."
    exit 0
  fi

  echo ""
  echo "---- End of iteration $i ----"
  echo ""
done

echo "Reached max iterations ($1)"
exit 1
