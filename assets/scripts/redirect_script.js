(function() {
        if (!document.getElementById('home-button')) {
          var button = document.createElement('button');
          button.id = 'home-button';
          button.innerText = 'Going Home in 4s';
          button.style.position = 'fixed';
          button.style.bottom = '20px';
          button.style.right = '20px';
          button.style.zIndex = '9999';
          button.style.padding = '10px 20px';
          button.style.backgroundColor = '#0052B4';
          button.style.color = '#fff';
          button.style.border = 'none';
          button.style.borderRadius = '5px';
          button.style.cursor = 'pointer';
          button.onclick = function() {
            HomeButtonChannel.postMessage('go_home');
          };
          document.body.appendChild(button);
            // Countdown logic
        var countdown = 4;
        var interval = setInterval(function() {
          countdown--;
          if (countdown > 0) {
            button.innerText = 'Go Home in ' + countdown + 's';
          } else {
            clearInterval(interval);
            button.innerText = 'Going Home';
            button.style.cursor = 'pointer';
            HomeButtonChannel.postMessage('go_home');
          }
        }, 1000);

          // Handle button click
        button.onclick = function() {
          clearInterval(interval); // Stop countdown
          HomeButtonChannel.postMessage('go_home');
        };

        }
      })();