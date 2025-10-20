<script>
(function () {
  // Detect env strictly from hostname. Works for:
  //   <branch>.<project>.pages.dev
  //   dev|test|staging.your-domain.tld
  const h = location.hostname.toLowerCase();

  // Returns: 'development' | 'test' | 'staging' | 'production'
  function detectEnv(host) {
    // custom subdomains
    if (host.startsWith('dev.') || host.includes('.dev.')) return 'development';
    if (host.startsWith('test.') || host.includes('.test.')) return 'test';
    if (host.startsWith('staging.') || host.includes('.staging.')) return 'staging';

    // Cloudflare Pages branch aliases: <branch>.<project>.pages.dev
    if (host.startsWith('development.')) return 'development';
    if (host.startsWith('test.'))        return 'test';
    if (host.startsWith('staging.'))     return 'staging';

    return 'production'; // anything else is prod
  }

  const ENV = detectEnv(h);

  // Expose globally if you need it elsewhere
  window.APP_ENV = {
    name: ENV,
    isProd: ENV === 'production',
    isStaging: ENV === 'staging',
    isTest: ENV === 'test',
    isDev: ENV === 'development'
  };

  // If there is an #envPill element, set/hide it accordingly
  document.addEventListener('DOMContentLoaded', () => {
    const pill = document.getElementById('envPill');
    if (!pill) return;
    if (ENV === 'production') {
      pill.style.display = 'none';            // hide on prod
    } else {
      pill.textContent = ENV.toUpperCase();   // show exact branch env
      pill.style.display = '';
    }
  });
})();
</script>
