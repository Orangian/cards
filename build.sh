          echo "GITHUB_WORKSPACE = $GITHUB_WORKSPACE"
          echo "github.workspace = ${{ github.workspace }}"
          echo "pr.ref = ${{github.event.pull_request.head.ref}}"
          echo "github.ref = ${{ github.ref }}"
          echo "$GITHUB_CONTEXT"
           echo $GITHUB_WORKSPACE && pwd && echo ${{github.ref}}
