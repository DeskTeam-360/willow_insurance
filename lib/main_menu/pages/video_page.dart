import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../services/data_service.dart';
import '../../../models/data_init_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VideoPage extends StatefulWidget {
  VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<VideoGuide> get videos {
    final dataService = DataService();
    final data = dataService.cachedData;
    if (data != null) {
      // Sort by order
      final sortedVideos = List<VideoGuide>.from(data.videoGuide);
      sortedVideos.sort((a, b) => a.order.compareTo(b.order));
      return sortedVideos;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              ),
              color: Color(0xFF71A33F),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/images/back_button.svg',
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      Color(0xFFffffff),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/willow_logo_white.png',
                  height: 30,
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          // Title "Important Note"
          Center(
            child: Text(
              'Video Guides',
              style: TextStyle(
                color: Color(0xFF497844),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: videos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No videos available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      final hasFeaturedImage =
                          video.featuredImage != null &&
                          video.featuredImage != false &&
                          video.featuredImage.toString().isNotEmpty;
                      final featuredImageStr = hasFeaturedImage
                          ? video.featuredImage.toString()
                          : '';
                      final isNetworkImage = hasFeaturedImage &&
                          featuredImageStr.startsWith('http');
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showVideoModal(context, video);
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: hasFeaturedImage
                                    ? (isNetworkImage
                                          ? Image.network(
                                              featuredImageStr,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      height: 200,
                                                      color: Color(0xFF6DA544),
                                                      child: Icon(
                                                        Icons.video_library,
                                                        color: Colors.white,
                                                        size: 50,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Image.asset(
                                              featuredImageStr,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      height: 200,
                                                      color: Color(0xFF6DA544),
                                                      child: Icon(
                                                        Icons.video_library,
                                                        color: Colors.white,
                                                        size: 50,
                                                      ),
                                                    );
                                                  },
                                            ))
                                    : Container(
                                        height: 200,
                                        color: Color(0xFF6DA544),
                                        child: Icon(
                                          Icons.video_library,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                              ),
                              // Play button overlay
                              Positioned.fill(
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              // Title overlay at bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    video.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showVideoModal(BuildContext context, VideoGuide video) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) =>
          VideoModalPlayer(videoUrl: video.video, videoTitle: video.title),
    );
  }
}

class VideoModalPlayer extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoModalPlayer({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
  });

  @override
  State<VideoModalPlayer> createState() => _VideoModalPlayerState();
}

class _VideoModalPlayerState extends State<VideoModalPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _isPlaying = _controller.value.isPlaying;
      });
      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      Navigator.of(context).pop();
      setState(() {
        _isFullScreen = false;
      });
    } else {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(
                controller: _controller,
                videoTitle: widget.videoTitle,
                onExit: () {
                  setState(() {
                    _isFullScreen = false;
                  });
                },
              ),
              fullscreenDialog: true,
            ),
          )
          .then((_) {
            setState(() {
              _isFullScreen = false;
            });
          });
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF6DA544),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.videoTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _controller.pause();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Video player
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = MediaQuery.of(context).size.height * 0.6;
                
                double aspectRatio = 16 / 9;
                if (_isInitialized && _controller.value.aspectRatio > 0) {
                  aspectRatio = _controller.value.aspectRatio;
                }
                
                // Calculate dimensions based on aspect ratio
                double videoWidth = maxWidth;
                double videoHeight = videoWidth / aspectRatio;
                
                // If video is too tall (portrait), constrain by height
                if (videoHeight > maxHeight) {
                  videoHeight = maxHeight;
                  videoWidth = videoHeight * aspectRatio;
                }
                
                return Container(
                  width: videoWidth,
                  height: videoHeight,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6DA544),
                            ),
                          ),
                        )
                      : _isInitialized
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: videoWidth,
                              height: videoHeight,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: _controller.value.size.width,
                                  height: _controller.value.size.height,
                                  child: VideoPlayer(_controller),
                                ),
                              ),
                            ),
                            // Play/Pause overlay button
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load video',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
            // Video controls
            if (_isInitialized)
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Progress bar
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Color(0xFF6DA544),
                        bufferedColor: Colors.grey[300]!,
                        backgroundColor: Colors.grey[600]!,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            final currentPosition = _controller.value.position;
                            final newPosition =
                                currentPosition - Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition < Duration.zero
                                  ? Duration.zero
                                  : newPosition,
                            );
                          },
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            final currentPosition = _controller.value.position;
                            final duration = _controller.value.duration;
                            final newPosition =
                                currentPosition + Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition > duration ? duration : newPosition,
                            );
                          },
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            _isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoTitle;
  final VoidCallback onExit;

  const FullScreenVideoPlayer({
    super.key,
    required this.controller,
    required this.videoTitle,
    required this.onExit,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_videoListener);
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isControlsVisible) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      _isControlsVisible = _showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    setState(() {
      _isPlaying = widget.controller.value.isPlaying;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _seekBackward() {
    final currentPosition = widget.controller.value.position;
    final newPosition = currentPosition - Duration(seconds: 10);
    widget.controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _seekForward() {
    final currentPosition = widget.controller.value.position;
    final duration = widget.controller.value.duration;
    final newPosition = currentPosition + Duration(seconds: 10);
    widget.controller.seekTo(newPosition > duration ? duration : newPosition);
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // Video player - full screen
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),
              // Controls overlay
              if (_showControls)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Column(
                      children: [
                        // Top bar with title and close button
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.videoTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  widget.onExit();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        // Center play/pause button
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bottom controls
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Progress bar
                              VideoProgressIndicator(
                                widget.controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Color(0xFF6DA544),
                                  bufferedColor: Colors.grey[300]!,
                                  backgroundColor: Colors.grey[600]!,
                                ),
                              ),
                              SizedBox(height: 16),
                              // Control buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: _seekBackward,
                                  ),
                                  SizedBox(width: 20),
                                  IconButton(
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    onPressed: _togglePlayPause,
                                  ),
                                  SizedBox(width: 20),
                                  IconButton(
                                    icon: Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: _seekForward,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
