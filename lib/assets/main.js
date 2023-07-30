export function init(ctx, payload) {
    ctx.importCSS("main.css");
    ctx.importCSS(
      "https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap"
    );
    ctx.importCSS(
      "https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.min.css"
    );
    ctx.importJS("https://unpkg.com/alpinejs@3.10.5/dist/cdn.min.js");
  
    ctx.root.innerHTML = `
      <div class="app" x-data="{helpBoxOpen: false}">
        <form>
          <div class="container">
            <div class="row header">
              <div class="icon-logo">
                <img src="discord_logo.svg">
              </div>
              <div class="inline-field">
                <label class="inline-input-label">Webhook URL</label>
                <input class="input input--xs input-text" id="webhook_url" placeholder="/webhooks/<channel>/<token>"readonly>
              </div>
              <div class="grow"></div>
              <button type="button" class="icon-button" @click="helpBoxOpen = !helpBoxOpen">
                <i class="ri ri-questionnaire-line" aria-hidden="true"></i>
              </button>
            </div>
            <div class="help-box" x-cloak x-show="helpBoxOpen">
              <div class="section">
                <p>
                  This Smart cell sends a message to a Discord channel. In order to use it, you need to
                  <a href="https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks" target="_blank">create a Discord webhook and get the URL</a>.
                </p>
              </div>
              <div class="section">
                <p>
                  To dynamically inject values into the query use double curly braces, like {{name}}.
                </p>
              </div>
            </div>
            <div class="row">
              <div class="field grow">
                <label class="input-label">Message</label>
                <textarea id="message" rows="10" class="input input--text-area" placeholder="Insert your Discrod message here..."></textarea>
              </div>
            </div>
          </div>
        </form>
      </div>
    `;
  
    const webhookUrlEl = document.getElementById("webhook_url");
    webhookUrlEl.value = payload.fields.webhook_url_secret_name;
  
    const messageEl = document.getElementById("message");
    messageEl.value = payload.fields.message;
  
    messageEl.addEventListener("change", (event) => {
      ctx.pushEvent("update_message", event.target.value)
    });
  
    webhookUrlEl.addEventListener("click", (event) => {
      ctx.selectSecret((secret_name) => {
        ctx.pushEvent("update_webhook_url_secret_name", secret_name);
      }, "DISCORD_WEBHOOK_URL")
    });
  
    ctx.handleEvent("update_webhook_url_secret_name", (webhook_url_secret_name) => {
      webhookUrlEl.value = webhook_url_secret_name;
    });
  
    ctx.handleSync(() => {
      // Synchronously invokes change listeners
      document.activeElement &&
        document.activeElement.dispatchEvent(new Event("change"));
    });
  }