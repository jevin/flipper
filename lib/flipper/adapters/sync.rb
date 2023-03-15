require "flipper/adapters/sync/synchronizer"
require "flipper/adapters/sync/interval_synchronizer"

module Flipper
  module Adapters
    # TODO: Syncing should happen in a background thread on a regular interval
    # rather than in the main thread only when reads happen.
    class Sync
      include ::Flipper::Adapter

      # Public: The name of the adapter.
      attr_reader :name

      # Public: The synchronizer that will keep the local and remote in sync.
      attr_reader :synchronizer

      # Public: Build a new sync instance.
      #
      # local - The local flipper adapter that should serve reads.
      # remote - The remote flipper adapter that should serve writes and update
      #          the local on an interval.
      # interval - The Float or Integer number of seconds between syncs from
      # remote to local. Default value is set in IntervalSynchronizer.
      def initialize(local, remote, synchronizer: nil, interval: IntervalSynchronizer::DEFAULT_INTERVAL, **synchronizer_options)
        @name = :sync
        @local = local
        @remote = remote
        @synchronizer = synchronizer || IntervalSynchronizer.new(
          Synchronizer.new(@local, @remote, raise_exceptions: false, **synchronizer_options),
          interval: interval,
        )
        synchronize
      end

      def features
        synchronize
        @local.features
      end

      def get(feature)
        synchronize
        @local.get(feature)
      end

      def get_multi(features)
        synchronize
        @local.get_multi(features)
      end

      def get_all
        synchronize
        @local.get_all
      end

      def add(feature)
        @remote.add(feature).tap { @local.add(feature) }
      end

      def remove(feature)
        @remote.remove(feature).tap { @local.remove(feature) }
      end

      def clear(feature)
        @remote.clear(feature).tap { @local.clear(feature) }
      end

      def enable(feature, gate, thing)
        @remote.enable(feature, gate, thing).tap do
          @local.enable(feature, gate, thing)
        end
      end

      def disable(feature, gate, thing)
        @remote.disable(feature, gate, thing).tap do
          @local.disable(feature, gate, thing)
        end
      end

      private

      def synchronize
        @synchronizer.call
      end
    end
  end
end
