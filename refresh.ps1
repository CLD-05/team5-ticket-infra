kubectl patch application ticket-platform-root -n argocd --type=merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
