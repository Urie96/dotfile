-- lazydeck plugin configuration
deck.config {
  plugins = {
    -- 'urie96/minimal.lazydeck',
    {
      'urie96/bookmarks.lazydeck',
      keys = {
        { 'ma', function() require('bookmarks').add() end, desc = 'add current page to bookmarks' },
      },
    },
    'urie96/rclone.lazydeck',
    {
      'urie96/audiobookshelf.lazydeck',
      config = function()
        require('audiobookshelf').setup {
          url = 'https://audiobook.lubui.com:8443',
          token = os.getenv 'AUDIOBOOKSHELF_TOKEN',
          library_id = '1824413f-cbf0-41e4-8b88-c1aab95c7f40',
        }
      end,
    },
    {
      'urie96/github.lazydeck',
      config = function()
        require('github').setup {
          token = os.getenv 'GITHUB_TOKEN',
        }
      end,
    },
    {
      'urie96/netease-music.lazydeck',
      config = function()
        os.execute 'ssh -f -N -L 127.0.0.1:3000:127.0.0.1:3110 home.lubui.com &>/dev/null'
        require('netease-music').setup {
          base_url = 'http://localhost:3000',
          uid = '1622973455',
          cookie = 'MUSIC_U=',
        }
      end,
    },
    'urie96/adb.lazydeck',
    'urie96/hackernews.lazydeck',
    {
      'urie96/file.lazydeck',
      config = function()
        require('file').setup {
          root = os.getenv 'HOME',
        }
      end,
    },
    'urie96/aria2.lazydeck',
    {
      'urie96/freshrss.lazydeck',
      config = function()
        require('freshrss').setup {
          url = 'https://rss.lubui.com:8443/api/greader.php',
          login = 'urie',
          password = os.getenv 'FRESHRSS_PASSWORD',
        }
      end,
    },
    'urie96/music.lazydeck',
    {
      'urie96/opensubsonic.lazydeck',
      config = function()
        require('opensubsonic').setup {
          url = 'https://music.lubui.com:8443',
          username = 'urie',
          password = os.getenv 'NAVIDROME_PASSWORD',
        }
      end,
    },
    -- Local directory plugin example:
    -- { dir = 'plugins/myplugin.lazydeck' },
    'urie96/process.lazydeck',
    'urie96/quick-access-tools.lazydeck',
    'urie96/himalaya.lazydeck',
    'urie96/systemd.lazydeck',
    'urie96/launchd.lazydeck',
    'urie96/docker.lazydeck',
    {
      'urie96/sftp.lazydeck',
      config = function()
        require('sftp').setup {
          profiles = {
            home = {
              host = 'home.lubui.com',
              base_dir = '/home/urie',
            },
          },
        }
      end,
    },
    {
      'urie96/memos.lazydeck',
      config = function()
        require('memos').setup {
          token = os.getenv 'MEMOS_TOKEN',
          base_url = 'https://memos.lubui.com:8443',
        }
      end,
    },
  },
}
