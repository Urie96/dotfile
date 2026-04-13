-- lazycmd plugin configuration
lc.config {
  plugins = {
    'urie96/minimal.lazycmd',
    {
      'urie96/github.lazycmd',
      config = function()
        require('github').setup {
          token = os.getenv 'GITHUB_TOKEN',
        }
      end,
    },
    {
      'urie96/netease-music.lazycmd',
      config = function()
        os.execute 'ssh -f -N -L 127.0.0.1:3000:127.0.0.1:3110 home.lubui.com &>/dev/null'
        require('netease-music').setup {
          base_url = 'http://localhost:3000',
          uid = '1622973455',
          cookie = 'MUSIC_U=',
        }
      end,
    },
    'urie96/adb.lazycmd',
    'urie96/file.lazycmd',
    'urie96/aria2.lazycmd',
    {
      'urie96/freshrss.lazycmd',
      config = function()
        require('freshrss').setup {
          url = 'https://rss.lubui.com:8443/api/greader.php',
          login = 'urie',
          password = os.getenv 'FRESHRSS_PASSWORD',
        }
      end,
    },
    'urie96/mpv.lazycmd',
    {
      'urie96/opensubsonic.lazycmd',
      config = function()
        require('opensubsonic').setup {
          url = 'https://music.lubui.com:8443',
          username = 'urie',
          password = os.getenv 'NAVIDROME_PASSWORD',
        }
      end,
    },
    -- Local directory plugin example:
    -- { dir = 'plugins/myplugin.lazycmd' },
    'urie96/process.lazycmd',
    'urie96/quick-access-tools.lazycmd',
    'urie96/himalaya.lazycmd',
    'urie96/systemd.lazycmd',
    'urie96/launchd.lazycmd',
    'urie96/docker.lazycmd',
    {
      'urie96/sftp.lazycmd',
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
      'urie96/memos.lazycmd',
      config = function()
        require('memos').setup {
          token = os.getenv 'MEMOS_TOKEN',
          base_url = 'https://memos.lubui.com:8443',
        }
      end,
    },
  },
}
