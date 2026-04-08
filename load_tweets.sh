#!/bin/sh

set -e

files='
test-data.zip
'

NORMALIZED_DB='postgresql://postgres:pass@localhost:1981/postgres'
DENORMALIZED_DB='postgresql://postgres:pass@localhost:1076/postgres'

echo 'load normalized'
for file in $files; do
    python3 load_tweets.py --db "$NORMALIZED_DB" --inputs "$file"
done

echo 'load denormalized'
for file in $files; do
    unzip -p "$file" \
      | python3 -c "import sys; [sys.stdout.write(line.replace(r'\\u0000', '')) for line in sys.stdin]" \
      | psql "$DENORMALIZED_DB" -c "\copy tweets_jsonb(data) FROM STDIN WITH (FORMAT csv, DELIMITER E'\t', QUOTE E'\b')"
done
