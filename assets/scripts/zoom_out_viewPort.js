 if (!document.querySelector('meta[name="viewport"]')) {
        var meta = document.createElement('meta');
        meta.name = "viewport";
        meta.content = "width=device-width, initial-scale=0.8, maximum-scale=0.8, user-scalable=no";
        document.head.appendChild(meta);
      } else {
        document.querySelector('meta[name="viewport"]').setAttribute(
          'content', 'width=device-width, initial-scale=0.8, maximum-scale=0.8, user-scalable=no');
      }