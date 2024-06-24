import React from 'react';

interface VideoPlayerProps {
  src: string;
  onLoadedData: () => void;
  className?: string;
}

const VideoPlayer: React.FC<VideoPlayerProps> = ({ src, onLoadedData, className }) => {
  return (
    <video
      src={src}
      onLoadedData={onLoadedData}
      className={className}
      autoPlay
      loop
      muted
      playsInline
    >
      Your browser does not support the video tag.
    </video>
  );
};

export default VideoPlayer;
