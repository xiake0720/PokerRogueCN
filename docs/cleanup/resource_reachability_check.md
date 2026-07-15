# Resource reachability check

- Status: **PASS**
- Errors: **0**
- Warnings: **1**
- Production scenes: **24**
- Runtime images: **296**; direct/dynamic **216**; review **0**
- Dynamic manifest resources: **170**; poker faces **52**
- Theme styles: **111**; duplicate groups **0**

## Errors

None.

## Warnings

- `unreferenced_runtime_images` `assets/ui/runtime` — 80 images are not directly reachable; 80 are reproducible pipeline outputs and 0 require review

## Runtime image review queue

None.

Run in CI:

```powershell
python tools/audits/check_resource_reachability.py
```
