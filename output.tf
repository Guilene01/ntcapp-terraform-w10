name: Debug Secret
on:
  workflow_dispatch:

jobs:
  debug:
    runs-on: ubuntu-latest
    steps:
      - name: Check Secret
        run: |
          echo "AWS_ROLE_ARN secret value: '${{ secrets.AWS_ROLE_ARN }}'"
          echo "Secret length: ${#AWS_ROLE_ARN}"
          if [ -z "${{ secrets.AWS_ROLE_ARN }}" ]; then
            echo "❌ AWS_ROLE_ARN secret is EMPTY!"
          else
            echo "✅ AWS_ROLE_ARN secret is set"
          fi