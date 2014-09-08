require "pathname"

require "vagrant/action/builder"

ENV['VMRUN_PATH'] = "/Applications/VMware\ Fusion.app/Contents/Library/vmrun"

module VagrantPlugins
  module VMwareProvider
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to halt the remote machine.
      def self.action_halt
        raise "not yet implemented"
      end

      # This action is called to terminate the remote machine.
      def self.action_destroy
        raise "not yet implemented"
      end

      # This action is called when `vagrant provision` is called.
      def self.action_provision
        raise "not yet implemented"
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Provision
            b2.use SyncFolders
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        raise "not yet implemented"
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAWS
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadState
        end
      end

      # This action is called to SSH into the machine.
      def self.action_ssh
        raise "not yet implemented"
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        raise "not yet implemented"
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHRun
          end
        end
      end

      def self.action_prepare_boot
        raise "not yet implemented"
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncFolders
          b.use WarnNetworks
          b.use ElbRegisterInstance
        end
      end

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_prepare_boot
                  b2.use StartInstance # restart this instance
                else
                  b2.use MessageAlreadyCreated # TODO write a better message
                end
              end
            else
              b1.use action_prepare_boot
              b1.use RunInstance # launch a new instance
            end
          end
        end
      end

      def self.action_reload
        raise "not yet implemented"
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAWS
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use action_halt
            b2.use Call, WaitForState, :stopped, 120 do |env2, b3|
              if env2[:result]
                b3.use action_up
              else
                # TODO we couldn't reach :stopped, what now?
              end
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :IsCreated, action_root.join("is_created")
      # autoload :IsStopped, action_root.join("is_stopped")
      # autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      # autoload :MessageNotCreated, action_root.join("message_not_created")
      # autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      # autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      # autoload :RunInstance, action_root.join("run_instance")
      # autoload :StartInstance, action_root.join("start_instance")
      # autoload :StopInstance, action_root.join("stop_instance")
      # autoload :SyncFolders, action_root.join("sync_folders")
      # autoload :TerminateInstance, action_root.join("terminate_instance")
      # autoload :TimedProvision, action_root.join("timed_provision") # some plugins now expect this action to exist
      # autoload :WaitForState, action_root.join("wait_for_state")
      # autoload :WarnNetworks, action_root.join("warn_networks")
      # autoload :ElbRegisterInstance, action_root.join("elb_register_instance")
      # autoload :ElbDeregisterInstance, action_root.join("elb_deregister_instance")
    end
  end
end