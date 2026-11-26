{{flutter_js}}
{{flutter_build_config}}

// This SDK generates a new version on each web build. The fallback also works
// when service worker generation is disabled with --pwa-strategy=none.
const buildVersion = {{flutter_service_worker_version}};
const bundleVersion = encodeURIComponent(buildVersion ?? Date.now());
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    const separator = build.mainJsPath.includes('?') ? '&' : '?';
    build.mainJsPath += `${separator}v=${bundleVersion}`;
  }
}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: buildVersion,
  },
});
